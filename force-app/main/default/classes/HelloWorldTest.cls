@isTest
private class HelloWorldTest {
    @isTest
    static void testSayHello() {
        Test.startTest();
        String result = HelloWorld.sayHello();
        Test.stopTest();
        System.assertEquals('Hello Velumani!', result);
    }
}