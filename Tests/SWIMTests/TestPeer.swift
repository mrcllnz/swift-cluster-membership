//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Cluster Membership open source project
//
// Copyright (c) 2018-2019 Apple Inc. and the Swift Cluster Membership project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Cluster Membership project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import ClusterMembership
@testable import SWIM
import XCTest

final class TestPeer: Hashable, SWIMPeerProtocol {
    var node: Node

    let lock: NSLock = NSLock()
    var messages: [TestPeer.Message] = []

    enum Message {
        case ping(payload: SWIM.GossipPayload, origin: AddressableSWIMPeer, timeout: SWIMTimeAmount, onComplete: (Result<SWIM.PingResponse, Error>) -> Void)
        case pingReq(target: AddressableSWIMPeer, payload: SWIM.GossipPayload, origin: AddressableSWIMPeer, timeout: SWIMTimeAmount, onComplete: (Result<SWIM.PingResponse, Error>) -> Void)
        case ack(target: AddressableSWIMPeer, incarnation: SWIM.Incarnation, payload: SWIM.GossipPayload)
        case nack(target: AddressableSWIMPeer)
    }

    init(node: Node) {
        self.node = node
    }

    func ping(
        payload: SWIM.GossipPayload,
        from origin: AddressableSWIMPeer,
        timeout: SWIMTimeAmount,
        onComplete: @escaping (Result<SWIM.PingResponse, Error>) -> Void
    ) {
        self.lock.lock()
        defer { self.lock.unlock() }

        self.messages.append(.ping(payload: payload, origin: origin, timeout: timeout, onComplete: onComplete))
    }

    func pingRequest(
        target: AddressableSWIMPeer,
        payload: SWIM.GossipPayload,
        from origin: AddressableSWIMPeer,
        timeout: SWIMTimeAmount,
        onComplete: @escaping (Result<SWIM.PingResponse, Error>) -> Void
    ) {
        self.lock.lock()
        defer { self.lock.unlock() }

        self.messages.append(.pingReq(target: target, payload: payload, origin: origin, timeout: timeout, onComplete: onComplete))
    }

    func ack(
        acknowledging: SWIM.SequenceNr,
        target: AddressableSWIMPeer,
        incarnation: SWIM.Incarnation,
        payload: SWIM.GossipPayload
    ) {
        self.lock.lock()
        defer { self.lock.unlock() }

        self.messages.append(.ack(target: target, incarnation: incarnation, payload: payload))
    }

    func nack(
        acknowledging: SWIM.SequenceNr,
        target: AddressableSWIMPeer
    ) {
        self.lock.lock()
        defer { self.lock.unlock() }

        self.messages.append(.nack(target: target))
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.node)
    }

    static func == (lhs: TestPeer, rhs: TestPeer) -> Bool {
        if lhs === rhs {
            return true
        }
        if type(of: lhs) != type(of: rhs) {
            return false
        }
        if lhs.node != rhs.node {
            return false
        }
        return true
    }
}
