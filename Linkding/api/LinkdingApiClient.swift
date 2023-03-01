//
// LinkdingApiClient.swift
// Created by Christian Wilhelm
//

import Foundation

public class LinkdingApiError: Error {
    public let message: String

    public init(message: String? = nil) {
        self.message = message ?? ""
    }
}

public class LinkdingApiClient: NSObject {
    private static let ENDPOINT_TAGS = "/api/tags/"
    private static let ENDPOINT_BOOKMARKS = "/api/bookmarks/"

    private let apiToken: String
    private let baseUrl: String
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder

    init(baseUrl: String, apiToken: String) {
        self.baseUrl = baseUrl.last == "/" ?
            String(baseUrl.dropLast()) :
            baseUrl
        self.apiToken = apiToken

        let dateFormatterWithFractional: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            return formatter
        }()
        let dateFormatterWithoutFractional: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            return formatter
        }()

        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.dateDecodingStrategy = .custom({
            let container = try $0.singleValueContainer()
            let dateStr = try container.decode(String.self)

            if let withFractional = dateFormatterWithFractional.date(from: dateStr) {
                return withFractional
            }

            if let withoutFractional = dateFormatterWithoutFractional.date(from: dateStr) {
                return withoutFractional
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to parse date string '\(dateStr)'")
        })
        self.jsonEncoder = JSONEncoder()
        self.jsonEncoder.dateEncodingStrategy = .formatted(dateFormatterWithFractional)
        self.jsonEncoder.outputFormatting = .withoutEscapingSlashes
    }

    private func buildRequest(url: URL, httpMethod: String? = nil, body: Data? = nil) throws -> URLRequest {
        var request = URLRequest(url: url)

        request.cachePolicy = .reloadIgnoringCacheData
        request.setValue("Token \(self.apiToken)", forHTTPHeaderField: "Authorization")

        if (httpMethod != nil) {
            request.httpMethod = httpMethod!
        }

        if (body != nil) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body!
        }

        return request
    }

    private func buildUrl(path: [String]) throws -> URL {
        guard var url = URL(string: self.baseUrl) else {
            throw LinkdingApiError(message: "Invalid URL: \(self.baseUrl)")
        }
        for part in path {
            url.appendPathComponent(part)
        }
        return url.absoluteURL
    }

    func loadBookmarks() async throws -> [LinkdingBookmarkDto] {
        var nextTargetUrl: URL? = try self.buildUrl(path: [LinkdingApiClient.ENDPOINT_BOOKMARKS])
        var allBookmarks: [LinkdingBookmarkDto] = []

        while (nextTargetUrl != nil) {
            let (next, bookmarks) = try await self.collectBookmarks(url: nextTargetUrl!)
            allBookmarks.append(contentsOf: bookmarks)
            nextTargetUrl = next != nil ? URL(string: next!) : nil
        }

        return allBookmarks
    }

    func loadTags() async throws -> [LinkdingTagDto] {
        var nextTargetUrl: URL? = try self.buildUrl(path: [LinkdingApiClient.ENDPOINT_TAGS])
        var allTags: [LinkdingTagDto] = []

        while (nextTargetUrl != nil) {
            let (next, tags) = try await self.collectTags(url: nextTargetUrl!)
            allTags.append(contentsOf: tags)
            nextTargetUrl = next != nil ? URL(string: next!) : nil
        }

        return allTags
    }

    private func performRequest(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let content: Data
        let response: URLResponse

        do {
            (content, response) = try await URLSession.shared.data(for: request)
        } catch (let error) {
            if let urlError = error as? URLError {
                throw LinkdingApiError(message: urlError.localizedDescription)
            } else {
                throw LinkdingApiError(message: "Unknown request error.")
            }
        }

        return (content, response as! HTTPURLResponse)
    }

    private func debugStringForCodingPath(_ path: [CodingKey]) -> String {
        return path.map { $0.stringValue }
            .joined(separator: " / ")
    }

    private func decodeJson<T: Decodable>(content: Data) throws -> T {
        do {
            return try self.jsonDecoder.decode(T.self, from: content)
        } catch let DecodingError.keyNotFound(key, context) {
            let path = self.debugStringForCodingPath(context.codingPath)
            throw LinkdingApiError(message: "Error when decoding JSON. Key '\(key.stringValue)' not found on path '\(path)'")
        } catch let DecodingError.valueNotFound(_, context) {
            let path = self.debugStringForCodingPath(context.codingPath)
            throw LinkdingApiError(message: "Error when decoding JSON. Value not found for path '\(path)'.")
        } catch let DecodingError.dataCorrupted(context) {
            let path = self.debugStringForCodingPath(context.codingPath)
            throw LinkdingApiError(message: "Error when decoding JSON. Data corrupted. Message: '\(context.debugDescription)' for path '\(path)'")
        } catch let DecodingError.typeMismatch(type, context) {
            let path = self.debugStringForCodingPath(context.codingPath)
            throw LinkdingApiError(message: "Error when decoding JSON. Type mismatch. Expect type '\(type)' for path '\(path)'")
        } catch {
            throw LinkdingApiError(message: "Unknown error while decoding JSON.")
        }
    }

    private func collectTags(url: URL) async throws -> (String?, [LinkdingTagDto]) {
        let (content, response) = try await self.performRequest(request: self.buildRequest(url: url))

        if (response.statusCode != 200) {
            throw LinkdingApiError(message: "Server responded with code \(response.statusCode).")
        }

        let tags: LinkdingTagListDto = try self.decodeJson(content: content)
        return (tags.next, tags.results)
    }

    private func collectBookmarks(url: URL) async throws -> (String?, [LinkdingBookmarkDto]) {
        let (content, response) = try await self.performRequest(request: self.buildRequest(url: url))

        if (response.statusCode != 200) {
            throw LinkdingApiError(message: "Server responded with code \(response.statusCode).")
        }

        let bookmarks: LinkdingBookmarkDtoList = try self.decodeJson(content: content)
        return (bookmarks.next, bookmarks.results)
    }

    func createBookmark(url: String, title: String, description: String, isArchived: Bool, unread: Bool, shared: Bool, tagNames: [String]) async throws -> LinkdingBookmarkDto {
        guard let apiUrl: URL = try? self.buildUrl(path: [LinkdingApiClient.ENDPOINT_BOOKMARKS]) else {
            throw LinkdingApiError()
        }
        guard let postBody = try? self.jsonEncoder.encode(LinkdingBookmarkUpdateDto(url: url, title: title, description: description, isArchived: isArchived, unread: unread, shared: shared, tagNames: tagNames)) else {
            throw LinkdingApiError()
        }
        let (content, response) = try await self.performRequest(request: self.buildRequest(url: apiUrl, httpMethod: "POST", body: postBody))

        if (response.statusCode != 201) {
            throw LinkdingApiError(message: "Server responded with code \(response.statusCode).")
        }

        return try self.decodeJson(content: content)
    }

    func updateBookmark(serverId: Int, url: String, title: String, description: String, isArchived: Bool, unread: Bool, shared: Bool, tagNames: [String]) async throws -> LinkdingBookmarkDto {
        guard let apiUrl: URL = try? self.buildUrl(path: [LinkdingApiClient.ENDPOINT_BOOKMARKS, String("\(serverId)/")]) else {
            throw LinkdingApiError()
        }

        guard let postBody = try? self.jsonEncoder.encode(LinkdingBookmarkUpdateDto(url: url, title: title, description: description, isArchived: isArchived, unread: unread, shared: shared, tagNames: tagNames)) else {
            throw LinkdingApiError()
        }

        let (content, response) = try await self.performRequest(request: self.buildRequest(url: apiUrl, httpMethod: "PUT", body: postBody))

        if (response.statusCode != 200) {
            throw LinkdingApiError(message: "Server responded with code \(response.statusCode).")
        }

        return try self.decodeJson(content: content)
    }

    func deleteBookmark(serverId: Int) async throws {
        guard let apiUrl: URL = try? self.buildUrl(path: [LinkdingApiClient.ENDPOINT_BOOKMARKS, String("\(serverId)/")]) else {
            throw LinkdingApiError()
        }

        let (_, response) = try await self.performRequest(request: self.buildRequest(url: apiUrl, httpMethod: "DELETE"))

        if (response.statusCode == 404) {
            // Bookmark was already deleted on the server
            return
        }

        if (response.statusCode != 204) {
            throw LinkdingApiError(message: "Server responded with code \(response.statusCode).")
        }
    }
    
    func createTag(name: String) async throws -> LinkdingTagDto {
        guard let apiUrl: URL = try? self.buildUrl(path: [LinkdingApiClient.ENDPOINT_TAGS]) else {
            throw LinkdingApiError()
        }
        
        guard let postBody = try? self.jsonEncoder.encode(LinkdingTagUpdateDto(name: name)) else {
            throw LinkdingApiError()
        }
        
        let (content, response) = try await self.performRequest(request: self.buildRequest(url: apiUrl, httpMethod: "POST", body: postBody))

        if (response.statusCode != 201) {
            throw LinkdingApiError(message: "Server responded with code \(response.statusCode).")
        }

        return try self.decodeJson(content: content)
    }
    
    func apiAvailable() async throws -> Bool {
        guard let url: URL = try? self.buildUrl(path: [LinkdingApiClient.ENDPOINT_BOOKMARKS]) else {
            return false
        }
        let (_, response) = try await self.performRequest(request: self.buildRequest(url: url))
        
        if (response.statusCode != 200) {
            return false
        }
        
        return true
    }
}
