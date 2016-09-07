import XCTest
@testable import MuttonChopTests
@testable import SpecTests

XCTMain([
    testCase(ReaderTests.allTests),
    testCase(ParserTests.allTests),
    testCase(CompilerTests.allTests),
    testCase(TemplateTests.allTests),

    testCase(CommentsTests.allTests),
    testCase(DelimitersTests.allTests),
    testCase(InterpolationTests.allTests),
    testCase(InvertedTests.allTests),
    testCase(PartialsTests.allTests),
    testCase(SectionsTests.allTests),
])
