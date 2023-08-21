class HydraTest extends Assert {
    Hydra h;
    h.init("configs", "config");

    {
        true => exitOnFailure;
        testGetStr();
        testGetInt();
        testBool();
        testGetFloat();
        // testGetArray(); // Not implemented yet
        testGetNested();

        testIsNull();
        testIsConfig();
        testIsString();
        testIsNumber();
        testIsBool();
        testIsArray();
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

    public void testBool() {
        h.get("test_bool").get_bool() => int got;
        true => int want;

        assertEquals(want, got);
    }

    public void testIsNull() {
        assertTrue(h.get("test_null").is_null());
        assertFalse(h.get("test_num").is_null());
    }

    public void testIsConfig() {
        assertTrue(h.get("struct").is_config());
        assertFalse(h.get("test_num").is_config());
    }

    public void testIsString() {
        assertTrue(h.get("test_str").is_string());
        assertFalse(h.get("test_num").is_string());
    }

    public void testIsNumber() {
        assertTrue(h.get("test_num").is_number());
        assertFalse(h.get("test_string").is_number());
    }

    public void testIsBool() {
        assertTrue(h.get("test_bool").is_bool());
        assertFalse(h.get("test_string").is_bool());
    }

    public void testIsArray() {
        assertTrue(h.get("test_arr").is_array());
        assertFalse(h.get("test_string").is_number());
    }

    public void testGetArray() {
        h.get("test_arr").get_array() @=> Hydra got[];
        [1,2,3] @=> int want[];

        for (int i: Std.range(want.size())) {
            assertEquals(want[i], got[i].get_int());
        }
    }
}

HydraTest hydraTest;
1::samp => now;
