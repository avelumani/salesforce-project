/**
 * HelloWorldTest.cls
 *
 * Full coverage for HelloWorld.cls — targets >= 75% org coverage.
 * Covers all executable lines and branches in both methods:
 *   ✅ sayHello()              — 1 line
 *   ✅ sayHelloTo(name)        — 3 lines, 2 branches (blank + non-blank)
 *   ✅ sayHelloTo(null)        — null branch (same code path as blank)
 *   ✅ sayHelloTo(whitespace)  — trims and checks blank branch
 *
 * Policy compliance:
 *   ✅ @isTest annotation
 *   ✅ NO SeeAllData=true          (COMP-004 / PMD)
 *   ✅ Test.startTest/stopTest()   on every method
 *   ✅ System.assertEquals assert  on every method (PMD)
 */
@isTest
private class HelloWorldTest {

    // ── sayHello() ───────────────────────────────────────────────
    @isTest
    static void testSayHello_returnsExpectedGreeting() {
        Test.startTest();
        String result = HelloWorld.sayHello();
        Test.stopTest();

        System.assertEquals(
            'Hello Velumani!',
            result,
            'sayHello() should return the fixed greeting string'
        );
    }

    // ── sayHelloTo() — with a real name ─────────────────────────
    @isTest
    static void testSayHelloTo_withName_returnsPersonalisedGreeting() {
        Test.startTest();
        String result = HelloWorld.sayHelloTo('Velumani');
        Test.stopTest();

        System.assertEquals(
            'Hello, Velumani!',
            result,
            'sayHelloTo should return a personalised greeting using the provided name'
        );
    }

    // ── sayHelloTo() — with leading/trailing spaces ──────────────
    @isTest
    static void testSayHelloTo_withPaddedName_trimsProperly() {
        Test.startTest();
        String result = HelloWorld.sayHelloTo('  Velumani  ');
        Test.stopTest();

        System.assertEquals(
            'Hello, Velumani!',
            result,
            'sayHelloTo should trim whitespace from the name before using it'
        );
    }

    // ── sayHelloTo() — blank string (empty branch) ───────────────
    @isTest
    static void testSayHelloTo_withBlankString_returnsWorldFallback() {
        Test.startTest();
        String result = HelloWorld.sayHelloTo('');
        Test.stopTest();

        System.assertEquals(
            'Hello, World!',
            result,
            'sayHelloTo should fall back to World when given an empty string'
        );
    }

    // ── sayHelloTo() — whitespace only (blank branch) ────────────
    @isTest
    static void testSayHelloTo_withWhitespaceOnly_returnsWorldFallback() {
        Test.startTest();
        String result = HelloWorld.sayHelloTo('   ');
        Test.stopTest();

        System.assertEquals(
            'Hello, World!',
            result,
            'sayHelloTo should treat whitespace-only input as blank and fall back to World'
        );
    }

    // ── sayHelloTo() — null input (blank branch) ─────────────────
    @isTest
    static void testSayHelloTo_withNull_returnsWorldFallback() {
        Test.startTest();
        String result = HelloWorld.sayHelloTo(null);
        Test.stopTest();

        System.assertEquals(
            'Hello, World!',
            result,
            'sayHelloTo should treat null as blank and fall back to World'
        );
    }
}