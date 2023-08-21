class HydraTest extends Assert {
    Hydra h;
    h.init("configs", "config");

    {
        // true => exitOnFailure;
        testGetStr();
        testGetInt();
        testGetNested();
    }

    public void testGetStr() {
        h.get("test_str").get_string() => string got;
        "poop" => string want;

        assertEquals(want, got);
    }

    public void testGetNested() {
        h.get("struct").get("val_str").get_string() => string got;
        "pooop" => string want;

        assertEquals(want, got);
    }

    public void testGetInt() {
           h.get("test_num").get_int() => int got;
           3 => int want;

           assertEquals(want, got);
    }
}

HydraTest hydraTest;
1::samp => now;
