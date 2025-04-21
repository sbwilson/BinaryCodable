// Copyright 2019-present the BinaryCodable authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import BinaryCodable
import XCTest

struct DecodeHeader: BinaryDecodable {
  var prefix: UInt16
  var contents: Data
  var foundDelimiter: Data
  let delimiter: Data = Data([6,7,8])
  var suffix: UInt16
  
  
  init(from decoder: any BinaryDecoder) throws {
    var container = decoder.container(maxLength: nil)
    self.prefix = try container.decode(UInt16.self)
    self.contents = try container.decode(until: delimiter)
    self.foundDelimiter = try container.decode(length: delimiter.count)
    self.suffix = try container.decode(UInt16.self)
  }
}


final class DecodeToBinaryDelimiterTests: XCTestCase {

  func testDecodeUntilDelimiter() throws {
    // Given
    let data: [UInt8] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0x0A]
    let decoder = BinaryDataDecoder()
    
    // When
    let header = try decoder.decode(DecodeHeader.self, from: data)
    
    // Then
    XCTAssertTrue(header.prefix == 0x0100)
    XCTAssertTrue(header.contents == Data([2,3,4,5]))
    XCTAssertTrue(header.foundDelimiter == header.delimiter)
    XCTAssertTrue(header.suffix == 0x0A09)
  }
}
