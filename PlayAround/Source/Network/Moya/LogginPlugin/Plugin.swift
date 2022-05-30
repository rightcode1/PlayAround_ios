//
//  Plugin.swift
//  PlayAround
//
//  Created by 이남기 on 2022/05/11.
//


import Foundation
import Moya

final class MoyaLoggingPlugin: PluginType {
  // Request를 보낼 때 호출
  func willSend(_ request: RequestType, target: TargetType) {
    guard let httpRequest = request.request else {
      print("--> 유효하지 않은 요청")
      return
    }
    let url = httpRequest.description
    let method = httpRequest.httpMethod ?? "unknown method"
    var log = "----------------------------------------------------\n\n[\(method)] \(url)\n\n----------------------------------------------------\n"
    log.append("\n[API] : \(target)\n")
    if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
      log.append("\n[Header] : \(headers)\n")
    }
    if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: String.Encoding.utf8) {
      log.append("\n[httpBody] : \(bodyString)\n\n")
    }
    log.append("----------------------------------------------------")
//    print(log)
  }
  
  // Response가 왔을 때
  func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    switch result {
    case let .success(response):
      onSuceed(response, target: target, isFromError: false)
    case let .failure(error):
      onFail(error, target: target)
    }
  }
    
  func onSuceed(_ response: Response, target: TargetType, isFromError: Bool) {
    let request = response.request
    let url = request?.url?.absoluteString ?? "nil"
    let method = request?.httpMethod ?? "unknown method"
    let statusCode = response.statusCode
    var log = "--------------------------- \(url) 네트워크 통신 성공 ---------------------------"
    log.append("\n\n[\(statusCode)] [\(method)] \(url)\n")
    log.append("\n[API] : \(target)\n\n")
//    response.response?.allHeaderFields.forEach {
//      log.append("\($0): \($1)\n")
//    }
//    if let reString = String(bytes: response.data.prettyPrintedJSONString, encoding: String.Encoding.utf8) {
//      log.append("[Response] : \(reString)\n\n")
//    }
    if let reString = response.data.prettyPrintedJSONString {
      log.append("[Response] : \(reString)\n\n")
    }
//    log.append("------------------- END HTTP (\(response.data.count)-byte body) -------------------")
    log.append("----------------------------- END -----------------------------")
    print(log)
  }
    
  func onFail(_ error: MoyaError, target: TargetType) {
    if let response = error.response {
      onSuceed(response, target: target, isFromError: true)
      return
    }
    var log = "--------------------------- 네트워크 오류 ---------------------------"
    log.append("<-- \(error.errorCode) \(target)\n\n")
    log.append("\(error.failureReason ?? error.errorDescription ?? "unknown error")\n\n")
    log.append("<-- END HTTP")
    log.append("-------------------------------------------------------------")
    print(log)
  }
}
