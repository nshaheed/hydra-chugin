class HydraTest extends Assert {
    Hydra h;
    h.init("configs", "config");

    {
        // true => exitOnFailure;
        testGetStr();
        testGetInt();
        testGetFloat();
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

    public void testGetFloat() {
        h.get("test_float").get_float() => float got;
        3.5 => float want;

        assertEquals(want, got, 0.01);
    }
}

HydraTest hydraTest;
1::samp => now;
