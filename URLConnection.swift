//
//  URLConnection.swift
//  
//  Copyright (c) 2015年 evan3rd. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

class URLConnection: NSObject, NSURLConnectionDelegate {
  
  var _connection: NSURLConnection?
  var _request: NSURLRequest?
  var _data: NSMutableData?
  var _response: NSURLResponse?
  var _downloadSize: Double?
  
  var _completionBlock: ((data: NSData, response: NSURLResponse) -> Void)?
  var _errorBlock: ((error: NSError) -> Void)?
  var _uploadBlock: ((progress: Float) -> Void)?
  var _downloadBlock: ((progress: Float) -> Void)?
  
  class func asyncConnectionWithURLString(urlString: NSString?, completionBlock completion:((NSData, NSURLResponse) -> Void), errorBlock: ((error: NSError) -> Void)) {
    var request = NSURLRequest(URL: NSURL(string: urlString!)!)
    URLConnection.asyncConnectionWithRequest(request, completion: completion, errorBlock: errorBlock, uploadProgressBlock: nil, downloadProgressBlock: nil)
  }
  
  class func asyncConnectionWithRequest(request : NSURLRequest?, completion: (data: NSData, response: NSURLResponse) -> Void, errorBlock: (error: NSError) -> Void, uploadProgressBlock: ((progress: Float) -> Void)?, downloadProgressBlock: ((progress: Float) -> Void)?) {
    let connection = URLConnection(request: request, completion: completion, errorBlock: errorBlock, uploadProgressBlock: uploadProgressBlock, downloadProgressBlock: downloadProgressBlock)
    connection.start()
  }
  
  class func asyncConnectionWithRequest(request:NSURLRequest?, completionBlock completion:((NSData, NSURLResponse) -> Void), errorBlock: ((error: NSError) -> Void)) {
    URLConnection.asyncConnectionWithRequest(request, completion: completion, errorBlock: errorBlock, uploadProgressBlock: nil, downloadProgressBlock: nil)
  }
  
  init(request : NSURLRequest?, completion: (data: NSData, response: NSURLResponse) -> Void, errorBlock: (error: NSError) -> Void, uploadProgressBlock: ((progress: Float) -> Void)?, downloadProgressBlock: ((progress: Float) -> Void)?) {
    _request = request
    _completionBlock = completion
    _errorBlock = errorBlock
    _uploadBlock = uploadProgressBlock
    _downloadBlock = downloadProgressBlock
  }
  
  func start() {
    _connection = NSURLConnection(request: _request!, delegate: self)
    _data = NSMutableData()
    _connection?.start()
  }
  
  // MARK: - NSURLConnectionDelegate
  
  func connectionDidFinishLoading(connection: NSURLConnection) {
    if let block = _completionBlock {
      block(data: _data!, response: _response!)
    }
  }
  
  func connection(connection: NSURLConnection, didFailWithError error: NSError) {
    if let block = _errorBlock {
      block(error: error)
    }
  }
  
  func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
    _response = response
    _downloadSize = Double(_response!.expectedContentLength)
  }
  
  func connection(connection: NSURLConnection, didReceiveData data: NSData) {
    _data?.appendData(data)
    
    if _downloadSize != 1 {
      var progress = Float(data.length) / Float(_downloadSize!)
      
      if let block = _downloadBlock {
        block(progress: progress)
      }
    }
  }

  func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
    var progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    if let block = _uploadBlock {
      block(progress: progress)
    }
  }
}