public with sharing class HelloWorld {

    public static String sayHello() {
        return 'Hello Velumani!';
    }

    /**
     * @AuraEnabled(cacheable=true) — required so LWC greetingCard can
     * call this via @salesforce/apex/HelloWorld.sayHelloTo import.
     * cacheable=true makes it compatible with both @wire and imperative calls.
     */
    @AuraEnabled(cacheable=true)
    public static String sayHelloTo(String name) {
        if (String.isBlank(name)) {
            return 'Hello, World!';
        }
        return 'Hello, ' + name.trim() + '!';
    }

}