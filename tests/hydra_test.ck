class HydraTest extends Assert {
    Hydra h;
    h.init("configs", "config");

    {
        true => exitOnFailure;
        testGetStr();
        testGetInt();
        testGetBool();
        testGetFloat();
        testGetNested();
        testGetAssign();
        testGetArray();
        testGetArray2();

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

        testDir();

        testArgsOverwrite();
        chout <= IO.newline()
              <= "~~~~ Testing errors, expect console output below here ~~~~\n"
              <= IO.newline();
        testBadYaml();
        testBadGetString();
        testBadGetInt();
        testBadGetFloat();
        testBadGetBool();
        testBadGet();
        
        chout <= "success!" <= IO.newline();
    }

    public void testGetStr() {
        <<< "testGetStr" >>>;
        h.get("test_str").getString() => string got;
        "poop" => string want;

        assertEquals(want, got);

        h.getString("test_str")=> got;
        assertEquals(want, got);
    }

    public void testGetNested() {
        <<< "testGetNested" >>>;
        h.get("struct").get("val_str").getString() => string got;
        "pooop" => string want;

        assertEquals(want, got);
    }

    public void testGetAssign() {
        <<< "testGetAssign" >>>;
        h.get("test_num") @=> Hydra t;
        3 => int want;

        assertEquals(want, t.getInt());
    }

    public void testGetInt() {
        <<< "testGetInt" >>>;
        h.get("test_num").getInt() => int got;
        3 => int want;

        assertEquals(want, got);

        h.getInt("test_num") => got;
        assertEquals(want, got);
    }

    public void testGetFloat() {
        <<< "testGetFloat" >>>;
        h.get("test_float").getFloat() => float got;
        3.5 => float want;

        assertEquals(want, got, 0.01);

        h.getFloat("test_float") => got;
        assertEquals(want, got, 0.01);
    }

    public void testGetBool() {
        <<< "testGetBool" >>>;
        h.get("test_bool").getBool() => int got;
        true => int want;

        assertEquals(want, got);

        h.getBool("test_bool") => got;
        assertEquals(want, got);
    }

    public void testIsNull() {
        <<< "testIsNull" >>>;
        assertTrue(h.get("test_null").isNull());
        assertFalse(h.get("test_num").isNull());
    }

    public void testIsConfig() {
        <<< "testIsConfig" >>>;
        assertTrue(h.get("struct").isConfig());
        assertFalse(h.get("test_num").isConfig());
    }

    public void testIsString() {
        <<< "testIsString" >>>;
        assertTrue(h.get("test_str").isString());
        assertFalse(h.get("test_num").isString());
    }

    public void testIsNumber() {
        <<< "testIsNumber" >>>;
        assertTrue(h.get("test_num").isNumber());
        assertFalse(h.get("test_string").isNumber());
    }

    public void testIsBool() {
        <<< "testIsBool" >>>;
        assertTrue(h.get("test_bool").isBool());
        assertFalse(h.get("test_string").isBool());
    }

    public void testIsArray() {
        <<< "testIsArray" >>>;
        assertTrue(h.get("test_arr").isArray());
        assertFalse(h.get("test_string").isNumber());
    }

    public void testGetArray() {
        <<< "testGetArray" >>>;
        h.get("test_arr").getArray() @=> Hydra got[];
        [1,2,3] @=> int want[];

        assertEquals(want.size(), got.size());
        for (int i: Std.range(want.size())) {
            // <<< want[i], got[i].getInt() >>>;
            assertEquals(want[i], got[i].getInt());
        }
    }

    public void testGetArray2() {
        <<< "testGetArray2" >>>;
        h.getArray("test_arr")@=> Hydra got[];
        [1,2,3] @=> int want[];

        assertEquals(want.size(), got.size());
        for (int i: Std.range(want.size())) {
            // <<< want[i], got[i].getInt() >>>;
            assertEquals(want[i], got[i].getInt());
        }
    }


    public void testSetNull() {
        <<< "testSetNull" >>>;
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        p.get("test_num").set() @=> Hydra test_null;

        assertTrue(test_null.isNull());
    }

    public void testSetConfig() {
        <<< "testSetConfig" >>>;
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        // replace the number value and substitute in a config
        p.get("struct") @=> Hydra replace;
        p.get("test_num").set(replace) @=> Hydra test_config;

        assertTrue(test_config.isConfig());
        assertEquals(test_config.get("val1").getInt(), p.get("struct").get("val1").getInt());
    }

    public void testSetString() {
        <<< "testSetString" >>>;
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        "not a number!" => string want;

        // replace the number value and substitute in a config
        p.get("test_num").set(want) @=> Hydra replace;

        assertEquals(want, replace.getString());
    }

    public void testSetInt() {
        <<< "testSetInt" >>>;
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        42 => int want;

        // replace the number value and substitute in a config
        p.get("test_str").set(want) @=> Hydra replace;

        assertEquals(want, replace.getInt());
    }

    public void testSetFloat() {
        <<< "testSetFloat" >>>;
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        42.11111 => float want;

        // replace the number value and substitute in a config
        p.get("test_str").set(want) @=> Hydra replace;

        assertEquals(want, replace.getFloat(),0.0001);
    }

    public void testSetTrue() {
        <<< "testSetTrue" >>>;
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        // replace the number value and substitute in a config
        p.get("test_str").setTrue() @=> Hydra replace;

        assertTrue(replace.getBool());
    }
    public void testSetFalse() {
        <<< "testSetFalse" >>>;
        // stateful changes
        Hydra p;
        p.init("configs", "config");

        // replace the number value and substitute in a config
        p.get("test_str").setFalse() @=> Hydra replace;

        assertFalse(replace.getBool());
    }

    public void testArgsOverwrite() {
        <<< "testArgsOverwrite" >>>;
        Hydra p;
        ["test_null=false", "struct.val1=fork", "+struct.val2=18"] @=> string args[];
        p.init("configs", "config", args);
        
        p.get("test_null") @=> Hydra testNull;
        assertNotNull(testNull);
        assertTrue(testNull.isBool());
        assertFalse(testNull.getBool());

        p.get("struct").get("val1") @=> Hydra val1;
        assertNotNull(val1);
        assertEquals(val1.getString(), "fork");

        p.get("struct").get("val2") @=> Hydra val2;
        assertNotNull(val2);
        assertEquals(val2.getInt(), 18);
    }

    public void testBadYaml() {
        <<< "testBadYaml" >>>;
        Hydra p;
        p.init("configs", "bad");
        assertTrue(p.isNull());
    }

    public void testBadGetString() {
        <<< "testBadGetString" >>>;
        h.get("test_num").getString() => string got;
        string want;

        assertEquals(want, got);
    }

    public void testBadGetInt() {
        <<< "testBadGetInt" >>>;
        h.get("does_not_exist").getInt() => int got;
        int want;

        assertEquals(want, got);
    }

    public void testBadGetFloat() {
        <<< "testBadGetFloat" >>>;
        h.get("test_str").getFloat() => float got;
        float want;

        assertEquals(want, got, 0);
    }

    public void testBadGetBool() {
        <<< "testBadGetBool" >>>;
        h.get("test_str").getBool() => int got;
        int want;

        assertEquals(want, got);
    }

    public void testBadGet() {
       <<< "testBadGet" >>>;
       h.get("test_str").get("test") @=> Hydra got;

       assertTrue(got.isNull());
    }

    public void testDir() {
       <<< "testDir" >>>;
       h.dir() => string cwd;

       assertNotNull(cwd);
    }
}

HydraTest hydraTest;
1::samp => now;
