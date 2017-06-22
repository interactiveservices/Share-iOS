//
//  FaceBook.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 14/06/2017.
//
//

import Foundation
import FBSDKLoginKit

extension Share {
    
    open class Facebook:NSObject{
        
        public typealias Success = ([String:Any])->Void
        public typealias Failure = (FacebookAuthoriser.FacebookError)->Void
        public typealias ShareError = FacebookAuthoriser.FacebookError
        
        open var authoriser:FacebookAuthoriser? = nil
        
        public init(authoriser:FacebookAuthoriser? = nil){
            
            self.authoriser = authoriser
            super.init()
            
        }
        
        public struct Request {
            
            public typealias Paging = (pageLimit:PagesCount, pagingKey:String)?
            public var path:String
            public var method:String
            public var parameters:[String:Any]?
            public var paging:Paging?
            public internal(set) var result:[String:Any] = [:]
            
            mutating func decrementPage()->Bool {
                
                guard let page = self.paging else {
                    
                    return false
                }
                
                switch page!.pageLimit
                {
                    
                case .unlimited: return true
                    
                case .limited(let value):
                    
                    if value == 0 {
                        return false
                    }
                    self.paging = (PagesCount.limited(value - 1),page!.pagingKey)
                    
                    return true
                }
            }
            
            public init(path:String, method:String = "GET", parameters:[String:Any]? = nil, paging:Paging? = nil){
                
                self.path = path
                self.method = method
                self.parameters = parameters
                self.paging = paging
                
            }
        }
        
        public enum Data {
            case success([String:Any])
            case error(ShareError)
        }
        
        public enum PagesCount{
            
            case unlimited
            case limited(UInt)
            
            static var ´default´ = limited(10)
            
            var value:UInt {
                
                switch self
                {
                    
                case .unlimited: return  UInt.max
                case .limited(let value): return value
                    
                }
            }
        }
        
        open func getUserInfo(with completion:@escaping(Data)->Void){
            let request = Request(
                path: "/me",
                parameters: ["fields": "friends{name,id,picture{url}},picture.width(300).height(300){url},name,email"]
            )
            
            make(request: request,
                 completion: completion)
        }
        
        open func getFriends(with completion:@escaping(Data)->Void){
            
            let request = Request(path: "/me",
                                  parameters: ["fields":"friends{name,id,picture{url}},picture.width(300).height(300){url},name"],
                                  paging: (pageLimit:PagesCount.unlimited,
                                           pagingKey:"friends"))
            
            make(request: request,
                 completion: completion)
            
        }
        
        open func make(request:Request, completion:@escaping(Data)->Void) {
            
            guard FacebookAuthoriser.isAuthorised else {
                
                assert(authoriser != nil)
                
                self.authoriser?.authWith(success: { _ in
                    
                    self.call(request: request,
                              success: { completion(Data.success($0)) },
                              failure: { completion(Data.error($0)) })
                    
                }, failure: { completion(Data.error($0)) })
                return
            }
            
            self.call(request: request,
                      success: { completion(Data.success($0)) },
                      failure: { completion(Data.error($0)) })

        }
        
        private func call(request:Request, success:@escaping Success, failure:@escaping Failure) {
            
            var request = request
            let fbRquest = FBSDKGraphRequest(graphPath: request.path,
                                             parameters: request.parameters,
                                             httpMethod: request.method)
            
            let connection = FBSDKGraphRequestConnection()
            
            connection.add(fbRquest) { (_, data, error) in
                
                switch (data, error)
                {
                    
                case (_, .some(let error)): failure(.failed(error))
                    
                case (let data as [String:Any], _):
                    
                    //add new data to old values
                    if let info = request.paging {
                        
                        let oldValues:[Any] = data.fb_data(for: info!.pagingKey) ?? [Any]()
                        let newValues:[Any] = request.result[info!.pagingKey] as?  [Any] ?? [Any]()
                        
                        request.result[info!.pagingKey] = newValues + oldValues
                    }
                    else {
                        request.result = data
                    }
                    let shouldRequestNextPage = request.decrementPage()
                    
                    if shouldRequestNextPage,
                        let nextKey = data.fb_nextLink {
                        
                        request.path = nextKey
                        self.call(request: request, success: success, failure: failure)
                        
                        return
                    }
                    
                    success(request.result)
                    
                default:
                    assert(false)
                    failure(.failed(NSError.unknownFacebookError()))
                    
                }
            }
            
            connection.start()
        }
    }
}

extension Dictionary where Key == String  {
    
    func fb_data(for key:String)->[Any]? {
        return (self["data"] as? [String:Any])?[key] as? [Any]
    }
    
    var fb_nextLink:String? {
        return (self["paging"] as? [String:Any])?["next"] as? String
    }
    
    var fb_prevLink:String? {
        return (self["paging"] as? [String:Any])?["previous"] as? String
    }
}

extension NSError {
    
    static func unknownFacebookError()->NSError
    {
        return NSError(domain: "Share.Facebook", code: -2390523, userInfo: nil)
    }
}

