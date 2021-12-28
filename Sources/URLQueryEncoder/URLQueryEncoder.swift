// The MIT License (MIT)
//
// Copyright (c) 2021 Alexander Grebenyuk (github.com/kean).

import Foundation

#warning("should this be a struct?")
public class URLQueryEncoder {
    public var explode = true
    private var _explode = true
    
    public var delimeter = ","
    private var _delimeter = ","
    
    public var isDeepObject = false
    private var _isDeepObject = false
    
    /// By default, `.iso8601`.
    public var dateEncodingStrategy: DateEncodingStrategy = .iso8601
    
    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy {
        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        case iso8601
        
        /// Encode the `Date` as a UNIX timestamp (as a JSON number).
        case secondsSince1970

        /// Encode the `Date` as UNIX millisecond timestamp (as a JSON number).
        case millisecondsSince1970

        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)

        /// Encode the `Date` as a custom value encoded by the given closure.
        ///
        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
        case custom((Date) -> String)
    }
    
    #warning("this should be private")
    public fileprivate(set) var codingPath: [CodingKey] = []
    public fileprivate(set) var queryItems: [URLQueryItem] = []

    public var items: [(String, String?)] {
        queryItems.map { ($0.name, $0.value) }
    }
    
    /// Returns the query as a string.
    public var query: String? {
        urlComponents.query
    }
    
    /// Returns the query as a string with percent-encoded values.
    public var percentEncodedQuery: String? {
        urlComponents.percentEncodedQuery
    }
    
    private var urlComponents: URLComponents {
        var components = URLComponents()
        components.queryItems = queryItems
        return components
    }
    
    public init() {}
    
    #warning("make throwing?")
    #warning("simplify how configuration is passed")
    public func encode(_ value: Encodable, explode: Bool? = nil, delimeter: String? = nil, isDeepObject: Bool? = nil) {
        _explode = explode ?? self.explode
        _delimeter = delimeter ?? self.delimeter
        _isDeepObject = isDeepObject ?? self.isDeepObject
        try? value.encode(to: self)
    }
    
    public static func data(for queryItems: [URLQueryItem]) -> Data {
        var components = URLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery?.data(using: .utf8) ?? Data()
    }
}

private extension URLQueryEncoder {
    func encodeNil(forKey codingPath: [CodingKey]) throws {
        // Do nothing
    }
        
    func encode(_ value: String, forKey codingPath: [CodingKey]) throws {
        append(value, forKey: codingPath)
    }
    
    func encode(_ value: Bool, forKey codingPath: [CodingKey]) throws {
        append(value ? "true" : "false", forKey: codingPath)
    }
    
    func encode(_ value: Int, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: Int8, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: Int16, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: Int32, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: Int64, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: UInt, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: UInt8, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: UInt16, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: UInt32, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: UInt64, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: Double, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: Float, forKey codingPath: [CodingKey]) throws {
        append(String(value), forKey: codingPath)
    }
    
    func encode(_ value: URL, forKey codingPath: [CodingKey]) throws {
        append(value.absoluteString, forKey: codingPath)
    }
    
    func encode(_ value: Date, forKey codingPath: [CodingKey]) throws {
        let string: String
        switch dateEncodingStrategy {
        case .iso8601: string = iso8601Formatter.string(from: value)
        case .secondsSince1970: string = String(value.timeIntervalSince1970)
        case .millisecondsSince1970: string = String(Int(value.timeIntervalSince1970 * 1000))
        case .formatted(let formatter): string = formatter.string(from: value)
        case .custom(let closure): string = closure(value)
        }
        append(string, forKey: codingPath)
    }

    func encodeEncodable<T: Encodable>(_ value: T, forKey codingPath: [CodingKey]) throws {
        self.codingPath = codingPath
        switch value {
        case let value as String: try encode(value, forKey: codingPath)
        case let value as Bool: try encode(value, forKey: codingPath)
        case let value as Int: try encode(value, forKey: codingPath)
        case let value as Int8: try encode(value, forKey: codingPath)
        case let value as Int16: try encode(value, forKey: codingPath)
        case let value as Int32: try encode(value, forKey: codingPath)
        case let value as Int64: try encode(value, forKey: codingPath)
        case let value as UInt: try encode(value, forKey: codingPath)
        case let value as UInt8: try encode(value, forKey: codingPath)
        case let value as UInt16: try encode(value, forKey: codingPath)
        case let value as UInt32: try encode(value, forKey: codingPath)
        case let value as UInt64: try encode(value, forKey: codingPath)
        case let value as Double: try encode(value, forKey: codingPath)
        case let value as Float: try encode(value, forKey: codingPath)
        case let value as Date: try encode(value, forKey: codingPath)
        case let value as URL: try encode(value, forKey: codingPath)
        case let value: try value.encode(to: self)
        }
    }
    
    #warning("refactor")
    func append(_ value: String, forKey codingPath: [CodingKey]) {
        guard !codingPath.isEmpty else {
            return // Should never happen
        }
        let key = codingPath[0].stringValue
        if _explode {
            if codingPath.count == 2 { // Encoding an object
                if _isDeepObject {
                    queryItems.append(URLQueryItem(name: "\(key)[\(codingPath[1].stringValue)]", value: value))
                } else {
                    queryItems.append(URLQueryItem(name: codingPath[1].stringValue, value: value))
                }
            } else {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        } else {
            if codingPath.count == 2 { // Encoding an object
                let newValue = "\(codingPath[1].stringValue),\(value)"
                if var queryItem = queryItems.last, queryItem.name == key {
                    queryItem.value = [queryItem.value, newValue].compactMap({ $0 }).joined(separator: ",")
                    queryItems[queryItems.endIndex - 1] = queryItem
                } else {
                    queryItems.append(URLQueryItem(name: key, value: newValue))
                }
            } else { // Encoding an array or a primitive value
                if var queryItem = queryItems.last, queryItem.name == key {
                    queryItem.value = [queryItem.value, value].compactMap { $0 }.joined(separator: _delimeter)
                    queryItems[queryItems.endIndex - 1] = queryItem
                } else {
                    queryItems.append(URLQueryItem(name: key, value: value))
                }
            }
        }
    }
}

#warning("TODO: remove from extension")
extension URLQueryEncoder: Encoder {
    public var userInfo: [CodingUserInfoKey : Any] { return [:] }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(KeyedContainer<Key>(encoder: self, codingPath: codingPath))
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        return UnkeyedContanier(encoder: self, codingPath: codingPath)
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        return SingleValueContanier(encoder: self, codingPath: codingPath)
    }
}

private struct KeyedContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    let encoder: URLQueryEncoder
    let codingPath: [CodingKey]
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let codingPath = self.codingPath + [key]
        encoder.codingPath = codingPath
        defer { encoder.codingPath.removeLast() }
        try encoder.encodeEncodable(value, forKey: codingPath)
    }
    
    func encodeNil(forKey key: Key) throws {
        let codingPath = self.codingPath + [key]
        encoder.codingPath = codingPath
        defer { encoder.codingPath.removeLast() }
        try encoder.encodeNil(forKey: codingPath)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath + [key]))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        return UnkeyedContanier(encoder: encoder, codingPath: codingPath + [key])
    }
    
    func superEncoder() -> Encoder {
        encoder
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        encoder
    }
}
    
private final class UnkeyedContanier: UnkeyedEncodingContainer {
    var encoder: URLQueryEncoder
    var codingPath: [CodingKey]
    
    private(set) var count = 0
    
    init(encoder: URLQueryEncoder, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder, codingPath: codingPath))
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self
    }
    
    func superEncoder() -> Encoder {
        encoder
    }
    
    func encodeNil() throws {
        try encoder.encodeNil(forKey: codingPath)
        count += 1
    }
    
    func encode<T>(_ value: T) throws where T: Encodable {
        try encoder.encodeEncodable(value, forKey: codingPath)
        count += 1
    }
}

private struct SingleValueContanier: SingleValueEncodingContainer {
    let encoder: URLQueryEncoder
    var codingPath: [CodingKey]
    
    init(encoder: URLQueryEncoder, codingPath: [CodingKey]) {
        self.encoder = encoder
        self.codingPath = codingPath
    }
    
    mutating func encodeNil() throws {
        try encoder.encodeNil(forKey: codingPath)
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        encoder.codingPath = self.codingPath
        try encoder.encodeEncodable(value, forKey: codingPath)
    }
}

private let iso8601Formatter = ISO8601DateFormatter()