class HydraTest extends Assert {
    Hydra h;
    h.init("configs", "config");

    {
        true => exitOnFailure;
        testGetStr();
        testGetInt();
        testBool();
        testGetFloat();
        testGetNested();
        testGetAssign();
        // testGetArray(); // Not implemented yet

        testSetNull();
        testSetConfig();
        testSetString();
        testSetInt();
        testSetFloat();
        testSetTrue();
        testSetFalse();

        testIsNull();
        testIsConfig();
        testIsString();
        testIsNumber();
        testIsBool();
        testIsArray();

        <<< "success!" >>>;
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

    public void testGetAssign() {
        h.get("test_num") @=> Hydra t;
        3 => int want;

        assertEquals(want, t.get_int());
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

    public void testSetNull() {
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        p.get("test_num").set() @=> Hydra test_null;

        assertTrue(test_null.is_null());
    }

    public void testSetConfig() {
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        // replace the number value and substitute in a config
        p.get("struct") @=> Hydra replace;
        p.get("test_num").set(replace) @=> Hydra test_config;

        assertTrue(test_config.is_config());
        assertEquals(test_config.get("val1").get_int(), p.get("struct").get("val1").get_int());
    }

    public void testSetString() {
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        "not a number!" => string want;

        // replace the number value and substitute in a config
        p.get("test_num").set(want) @=> Hydra replace;

        assertEquals(want, replace.get_string());
    }

    public void testSetInt() {
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        42 => int want;

        // replace the number value and substitute in a config
        p.get("test_str").set(want) @=> Hydra replace;

        assertEquals(want, replace.get_int());
    }

    public void testSetFloat() {
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        42.11111 => float want;

        // replace the number value and substitute in a config
        p.get("test_str").set(want) @=> Hydra replace;

        assertEquals(want, replace.get_float(),0.0001);
    }

    public void testSetTrue() {
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        // replace the number value and substitute in a config
        p.get("test_str").set_true() @=> Hydra replace;

        assertTrue(replace.get_bool());
    }
    public void testSetFalse() {
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        // replace the number value and substitute in a config
        p.get("test_str").set_false() @=> Hydra replace;

        assertFalse(replace.get_bool());
    }
}

HydraTest hydraTest;
1::samp => now;
