// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import os.lock

public final class UnfairLock<Value> {
  private var lockPointer: UnsafeMutablePointer<os_unfair_lock>
  private var _value: Value

  public init(_ value: Value) {
    lockPointer = UnsafeMutablePointer<os_unfair_lock>.allocate(capacity: 1)
    lockPointer.initialize(to: os_unfair_lock())
    _value = value
  }

  deinit {
    lockPointer.deallocate()
  }

  public func value() -> Value {
    lock()
    defer { unlock() }
    return _value
  }

  @discardableResult
  public func withLock<Result>(_ body: (inout Value) throws -> Result) rethrows -> Result {
    lock()
    defer { unlock() }
    return try body(&_value)
  }

  private func lock() {
    os_unfair_lock_lock(lockPointer)
  }

  private func unlock() {
    os_unfair_lock_unlock(lockPointer)
  }
}
