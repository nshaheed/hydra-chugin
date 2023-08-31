//-----------------------------------------------------------------------------
// Entaro ChucK Developer!
// This is a Chugin boilerplate, generated by chuginate!
//-----------------------------------------------------------------------------

/* TODO LIST
   - [DONE] pass in args to python program (string interpolation?)
   - [DONE] take in the python output as std in (after converting to json)
   - [DONE] parse in as json
   - [DONE] make python script a string instead of a file
   - [TODO] Handle types
     - [DONE] String
     - [DONE] Int
     - [DONE] Float
     - [DONE] Bool
     - [INPR] (P1) Array
       - only return list of Hydra
     - [TODO] (P1) Dur 
       - parse string as Dur
     - [TODO] (P2) time 
     - [TODO] (P2) complex
     - [TODO] (P2) polar
     - [TODO] (P2) vec3 
     - [TODO] (P2) vec4 
   - [DONE] is_nil() - now to handle?
   - [DONE] add is_array/is_string/etc. type checkers
   - [INPR] set()
     - take in type, return Hydra
     - [DONE] set for configs and primitives
     - [TODO] set for array
   - [DONE] handle error case: if json conversion fails, print error and return nil
   - [TODO] get keys
     - would prefer this return an array instead.
   - [TODO] remove key
   - [DONE] outputs dir
     - make outputs dir (mkdir -p): ./outputs/YYYY-MM-DD/HH-MM-SS/
       - alternatively, have hydra make this and pass it as metadata (it already will?)
   - [DONE] maybe have more structured dict
     - hydra type
       - [DONE] hydra.get("key"): returns Hydra if contents is another hydra struct, error if it's a value
       - [DONE] hydra.int(): returns int if current Hydra object contains a value, error on
         missing or type conversion
       - [DONE] hydra.float() etc...
       - [DONE] ex: hydra.get("foo").get("bar").int() => int a;
   - [TODO] hydra.dir() - get proper output dir
     - [TODO] test just call chdir within the chugin
   - [TODO] hydra.disableChangeDir() - disable changing cwd
   - pass args override from cmd line (see if I can do this automatically)
     - chuck hydra.ck:foo=2:bar=4
   - [INPR] proper error handling
     - [INPR] handle get_*() failure (print to stderr, return null/0/"")
       - [TODO] handle array case once impelmented
       - [DONE] check what type it actually is and print that.
     - [TODO] check if python is installed
     - [TODO] check if hydra is installed (print pip message to run otherwise)
     - [DONE] gracefully handle parse failure
   - [TODO] Documentation
     - [TODO] Doc strings
     - [TODO] ckdoc
     - [TODO] Examples folder
     - [TODO] Video tutorial
     - [TODO] Written tutorial
 */

// this should align with the correct versions of these ChucK files
#include "chuck_dl.h"
#include "chuck_def.h"

// general includes
#include <stdio.h>
#include <limits.h>
#include <iostream>
#include <variant>
#include <sstream>
#include <filesystem>
#include <fstream>
#include <chrono>
#include <random>

#ifdef _WIN32
#include <Windows.h>
#include <io.h>
#endif

namespace fs = std::filesystem;

// json library
#include "nlohmann/json.hpp"
using json = nlohmann::json;

// declaration of chugin constructor
CK_DLL_CTOR(hydra_ctor);
// declaration of chugin desctructor
CK_DLL_DTOR(hydra_dtor);

// example of getter/setter
CK_DLL_MFUN(hydra_init);
CK_DLL_MFUN(hydra_init_args);
CK_DLL_MFUN(hydra_get);
CK_DLL_MFUN(hydra_get_str);
CK_DLL_MFUN(hydra_get_int);
CK_DLL_MFUN(hydra_get_float);
CK_DLL_MFUN(hydra_get_bool);
CK_DLL_MFUN(hydra_get_array);

CK_DLL_MFUN(hydra_is_null);
CK_DLL_MFUN(hydra_is_config);
CK_DLL_MFUN(hydra_is_str);
CK_DLL_MFUN(hydra_is_number);
CK_DLL_MFUN(hydra_is_bool);
CK_DLL_MFUN(hydra_is_array);

CK_DLL_MFUN(hydra_set_null);
CK_DLL_MFUN(hydra_set_config);
CK_DLL_MFUN(hydra_set_str);
CK_DLL_MFUN(hydra_set_int);
CK_DLL_MFUN(hydra_set_float);
CK_DLL_MFUN(hydra_set_true);
CK_DLL_MFUN(hydra_set_false);
CK_DLL_MFUN(hydra_set_array);

CK_DLL_MFUN(hydra_dir);

// this is a special offset reserved for Chugin internal data
t_CKINT hydra_data_offset = 0;


// class definition for internal Chugin data
// (note: this isn't strictly necessary, but serves as example
// of one recommended approach)
class Hydra
{
private:
  // The values in a hydra config are either YAML values or a
  // map of hydra configs. Here configs are recusively defined.
  using value_type = std::variant
    <std::monostate,
     std::map<std::string, Hydra*>,
     std::string,
     double,
     bool,
     std::vector<Hydra*>
     >;
  value_type value;

public:
  // constructor
  Hydra(std::string config_path, std::string config_name, std::vector<std::string> args) {
    // 1. Generate a python program to initialize all the hydra-y things
    // 2. Write the program to a temporary file 
    // 3. Run the python program - outputting:
    //    a. The path to the output dir
    //    b. The hydra config as a json file
    // 4. Parse the config as json
    // 5. Build up an internal representation of the config
      std::cout << "constructor called" << std::endl;
    std::string python_code = config_init(config_path, config_name);

    // Get the current working directory
    fs::path currentDir = fs::current_path();

    // Generate a unique filename in the current working directory
    auto now = std::chrono::system_clock::now();
    auto timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();
    std::random_device rd;
    std::mt19937 generator(rd());
    std::uniform_int_distribution<int> distribution(0, 9999);
    int random_number = distribution(generator);

    std::string tempFileName = "tempfile_" + std::to_string(timestamp) + "_" + std::to_string(random_number) + ".tmp";

    // Create and open the temporary file
    std::ofstream tmpFile(tempFileName);

    if (!tmpFile.is_open()) {
        throw std::runtime_error("Failed to create temporary file.");
    }

    // Write the Python code to the temporary file
    tmpFile << python_code;
    // Close the temporary file
    tmpFile.close();

  Hydra(std::string config_path, std::string config_name, std::vector<std::string> args) {

    // build the overrides from the args list
    std::string python_args = "";
    for (auto arg : args) {
      python_args.append(" ");
      python_args.append(arg);
    }
    // Execute the python program
    std::string cmd = "python " + tempFileName + python_args;
    std::string result = exec(cmd);

    // Delete the temporary file
    if (!fs::remove(tempFileName)) {
        throw std::runtime_error("Failed to delete temporary file.");
    }

    //std::cout << "result\n";
    //std::cout << result << std::endl << std::endl;;

    std::istringstream result_stream;
    result_stream.str(result);

    // get cwd (printed first)
    std::getline(result_stream, cwd);

    json j;
    try {
      j = json::parse(result_stream);
    } catch (json::parse_error& e) {
      // output exception information
      std::cerr << "Unable to parse " << config_name << ".yaml" << std::endl
                << "\tError message: " << e.what() << std::endl
                << "\tException id: " << e.id << std::endl;
      return;
    }

    build_hydra(j);
  }

  Hydra(json j) {
    build_hydra(j);
  }

  Hydra(std::string val) {
    value = val;
  }

  Hydra(double val) {
    value = val;
  }

  Hydra(bool val) {
    value = val;
  }

  Hydra(std::map<std::string, Hydra*> val) {
    value = val;
  }

  Hydra(std::vector<Hydra*> val) {
    value = val;
  }

  // initialize a null-valued Hydra
  Hydra() {
  }

  void build_hydra(json j) {
    if (j.is_string()) {
      std::string str_val = j.template get<std::string>();
      value = str_val;
    } else if (j.is_number()) {
      double num_val = j.template get<double>();
      value = num_val;
    } else if (j.is_boolean()) {
      bool bool_val = j.template get<bool>();
      value = bool_val;
    } else if (j.is_null()) {
      // This case does NOTHING for me. NOTHING.      I  HATE  YOU.
    } else if (j.is_object()) {
      // iterate through all elems to build up a map
      std::map<std::string, Hydra*> vals;

      for (auto& element : j.items()) {
        auto val = element.value();
        auto key = element.key();

        Hydra * elem = new Hydra(val);
        vals[key] = elem;
      }

      value = vals;
    } else if (j.is_array()) {
      std::vector<Hydra*> vals;

      for (auto& element : j.items()) {
        auto val = element.value();

        Hydra * elem = new Hydra(val);
        vals.push_back(elem);
      }

      value = vals;
    }
  }

  void set(std::string key, Hydra* val) {
    std::get<1>(value)[key] = val;
  }

  void set() {
    value = std::monostate();
  }

  void set(value_type v) {
    value = v;
  }

  // Get hydra value to be transformed into a hydra class
  Hydra* get(std::string key) {
    if (std::map<std::string, Hydra*>* val = std::get_if<1>(&value)) {
      return (*val)[key];
    }
    return new Hydra();
  }

  std::string get_string() {

    if (std::string* val = std::get_if<std::string>(&value)) {
      return *val;
    }

    std::cerr << "Unable to read Hydra value (" << this->get_type_string(&value) <<") as string" << std::endl;
    return "";
  }

  value_type get_value() {
    return value;
  }

  t_CKINT get_int() {
    if (double* val = std::get_if<double>(&value)) {
      return (int)*val;
    }

    std::cerr << "Unable to read Hydra value (" << this->get_type_string(&value) <<") as int" << std::endl;
    return 0;
  }

  t_CKFLOAT get_float() {
    if (double* val = std::get_if<double>(&value)) {
      return *val;
    }

    std::cerr << "Unable to read Hydra value (" << this->get_type_string(&value) <<") as float" << std::endl;
    return 0;
  }

  t_CKINT get_bool() {
    if (bool* val = std::get_if<bool>(&value)) {
      return (int)*val;
    }

    std::cerr << "Unable to read Hydra value (" << this->get_type_string(&value) <<") as bool" << std::endl;
    return 0;
  }

  std::vector<Hydra*> get_array() {
    if (std::vector<Hydra*>* val = std::get_if<std::vector<Hydra*>>(&value)) {
      return *val;
    }

    std::cerr << "Unable to read Hydra value (" << this->get_type_string(&value) <<") as array" << std::endl;
    return std::vector<Hydra*>();
  }

  t_CKINT is_null() {
    // check if variant is in monostate
    if(value.index() == 0) {
      return true;
    }

    return false;
  }

  t_CKINT is_config() {
    if (std::get_if<std::map<std::string, Hydra*>>(&value)) return true;
    return false;
  }

  t_CKINT is_string() {
    if (std::get_if<std::string>(&value)) return true;
    return false;
  }

  t_CKINT is_number() {
    if (std::get_if<double>(&value)) return true;
    return false;
  }

  t_CKINT is_bool() {
    if (std::get_if<bool>(&value)) return true;
    return false;
  }

  t_CKINT is_array() {
    if (std::get_if<std::vector<Hydra*>>(&value)) return true;
    return false;
  }

  // Get the current type of value (for printing)
  static std::string get_type_string(value_type* v) {
    if (v == NULL) {
      return "null";
    }
    switch (v->index()) {
    case 0:
      return "null";
    case 1:
      return "config";
    case 2:
      return "string";
    case 3:
      return "number";
    case 4:
      return "bool";
    case 5:
      return "array";
    default:
      std::cerr << "Unable to find type of Hydra value" << std::endl;
      return "";
    }
  }

  // get the output dir of the app's run.
  std::string dir() {
    return cwd;
  }

  // // disable changing the output dir of the hydra app (not implemented yet)
  // std::string disableChangeDir() {

  // }
    
private:
  // The cwd of the run.
  std::string cwd;

  // execute cmd and return the stdout as a string
  // see the link for how to deal with windows
  // https://stackoverflow.com/questions/478898/how-do-i-execute-a-command-and-get-the-output-of-the-command-within-c-using-po
  std::string exec(std::string cmd) {
    std::array<char, 128> buffer;
    std::string result;
#ifdef _WIN32
    std::unique_ptr<FILE, decltype(&_pclose)> pipe(_popen(cmd.c_str(), "r"), _pclose);
#else
    std::unique_ptr<FILE, decltype(&pclose)> pipe(popen(cmd.c_str(), "r"), pclose);
#endif
    if (!pipe) {
      throw std::runtime_error("popen() failed!");
    }
    while (fgets(buffer.data(), buffer.size(), pipe.get()) != nullptr) {
      result += buffer.data();
    }

    return result;
  }

  std::string config_init(std::string config_path, std::string config_name) {
    // The python program to be run. This is embedded here rather than
    // as a file as it means I don't have to manage where the script is
    // relative to the chugin (which seems tricky to do)
    std::string config_init_str = R"(
import json
import sys

import hydra
from omegaconf import OmegaConf

@hydra.main(version_base=None, config_path=')" + config_path + R"(', config_name=')" + config_name +R"(')
def config_init(cfg):
    container = OmegaConf.to_container(cfg, resolve=True)
    hydra_cfg = hydra.core.hydra_config.HydraConfig.get()
    print(f'{hydra_cfg.runtime.output_dir}/')
    print(json.dumps(container))


config_init()

)";

    return config_init_str;
  }
};


// query function: chuck calls this when loading the Chugin
// NOTE: developer will need to modify this function to
// add additional functions to this Chugin
CK_DLL_QUERY( Hydra )
{
    // hmm, don't change this...
    QUERY->setname(QUERY, "Hydra");
    
    // begin the class definition
    // can change the second argument to extend a different ChucK class
    QUERY->begin_class(QUERY, "Hydra", "UGen");

    // register the constructor (probably no need to change)
    QUERY->add_ctor(QUERY, hydra_ctor);
    // register the destructor (probably no need to change)
    QUERY->add_dtor(QUERY, hydra_dtor);

    // init method
    QUERY->add_mfun(QUERY, hydra_init, "void", "init");
    QUERY->add_arg(QUERY, "string", "config_path");
    QUERY->add_arg(QUERY, "string", "config_name");

    QUERY->add_mfun(QUERY, hydra_init_args, "void", "init");
    QUERY->add_arg(QUERY, "string", "config_path");
    QUERY->add_arg(QUERY, "string", "config_name");
    QUERY->add_arg(QUERY, "string[]", "args");

    // Getters
    QUERY->add_mfun(QUERY, hydra_get, "Hydra", "get");
    QUERY->add_arg(QUERY, "string", "key");

    QUERY->add_mfun(QUERY, hydra_get_str, "string", "getString");
    QUERY->add_mfun(QUERY, hydra_get_int, "int", "getInt");
    QUERY->add_mfun(QUERY, hydra_get_float, "float", "getFloat");
    QUERY->add_mfun(QUERY, hydra_get_bool, "int", "getBool");
    QUERY->add_mfun(QUERY, hydra_get_array, "Hydra[]", "getArray");

    // Setters
    QUERY->add_mfun(QUERY, hydra_set_null, "Hydra", "set");
    QUERY->add_mfun(QUERY, hydra_set_config, "Hydra", "set");
    QUERY->add_arg(QUERY, "Hydra", "val");
    QUERY->add_mfun(QUERY, hydra_set_str, "Hydra", "set");
    QUERY->add_arg(QUERY, "string", "val");
    QUERY->add_mfun(QUERY, hydra_set_int, "Hydra", "set");
    QUERY->add_arg(QUERY, "int", "val");
    QUERY->add_mfun(QUERY, hydra_set_float, "Hydra", "set");
    QUERY->add_arg(QUERY, "float", "val");
    QUERY->add_mfun(QUERY, hydra_set_true, "Hydra", "setTrue");
    QUERY->add_mfun(QUERY, hydra_set_false, "Hydra", "setFalse");
    // TODO set array

    // Type checkers
    QUERY->add_mfun(QUERY, hydra_is_null, "int", "isNull");
    QUERY->add_mfun(QUERY, hydra_is_config, "int", "isConfig");
    QUERY->add_mfun(QUERY, hydra_is_str, "int", "isString");
    QUERY->add_mfun(QUERY, hydra_is_number, "int", "isNumber");
    QUERY->add_mfun(QUERY, hydra_is_bool, "int", "isBool");
    QUERY->add_mfun(QUERY, hydra_is_array, "int", "isArray");

    // hydra management functions
    QUERY->add_mfun(QUERY, hydra_dir, "string", "dir");
    
    // this reserves a variable in the ChucK internal class to store 
    // referene to the c++ class we defined above
    hydra_data_offset = QUERY->add_mvar(QUERY, "int", "@h_data", false);

    // end the class definition
    // IMPORTANT: this MUST be called!
    QUERY->end_class(QUERY);

    // wasn't that a breeze?
    return TRUE;
}

// implementation for the constructor
CK_DLL_CTOR(hydra_ctor)
{
  // get the offset where we'll store our internal c++ class pointer
  OBJ_MEMBER_INT(SELF, hydra_data_offset) = 0;
}


// implementation for the destructor
CK_DLL_DTOR(hydra_dtor)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);
    // check it
    if( h_obj )
      {
        // clean up
        delete h_obj;
        OBJ_MEMBER_INT(SELF, hydra_data_offset) = 0;
        h_obj = NULL;
    }
}

CK_DLL_MFUN(hydra_init_args)
{
  std::string config_path = GET_NEXT_STRING_SAFE(ARGS);
  std::string config_name = GET_NEXT_STRING_SAFE(ARGS);
  Chuck_Array4 * args = (Chuck_Array4 *) GET_NEXT_OBJECT(ARGS);

  if(args == NULL) {
    fprintf( stderr, "Hydra.init(): argument 'args' is null\n" );
    RETURN->v_object = 0;
    return;
  }

  std::vector<std::string> args_vector;

  t_CKINT size;
  API->object->array4_size(API, args, size);

  for (int i = 0; i < size; i++) {
    t_CKUINT arg;
    API->object->array4_get_idx(API, args, i, arg);

    // Chuck_String* arg = (Chuck_String*) args->m_vector[i];
    // args->get((t_CKUINT)i, (t_CKUINT*)arg);

    Chuck_String* arg_str = (Chuck_String*) arg;

    args_vector.push_back(arg_str->str());
  }

  // instantiate our internal c++ class representation
  Hydra * h_obj = new Hydra(config_path, config_name, args_vector);

  // store the pointer in the ChucK object member
  OBJ_MEMBER_INT(SELF, hydra_data_offset) = (t_CKINT) h_obj;
}


CK_DLL_MFUN(hydra_init)
{
  std::string config_path = GET_NEXT_STRING_SAFE(ARGS);
  std::string config_name = GET_NEXT_STRING_SAFE(ARGS);

  // instantiate our internal c++ class representation
  Hydra * h_obj = new Hydra(config_path, config_name, std::vector<std::string>());

  // store the pointer in the ChucK object member
  OBJ_MEMBER_INT(SELF, hydra_data_offset) = (t_CKINT) h_obj;
}


CK_DLL_MFUN(hydra_get)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    std::string key = GET_NEXT_STRING_SAFE(ARGS);

    Hydra * val = h_obj->get(key);

    // Allocate a Hydra object and return it
    Chuck_DL_Api::Object obj = API->object->create(API, SHRED, API->object->get_type(API, SHRED, "Hydra"));
    Chuck_Object * object = (Chuck_Object *) obj;
    OBJ_MEMBER_INT(object, hydra_data_offset) = (t_CKINT) val;

    RETURN->v_object = object;
}

CK_DLL_MFUN(hydra_get_str)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    std::string val = h_obj->get_string();
    RETURN->v_string = (Chuck_String*)API->object->create_string(API, SHRED, val.c_str());
}

CK_DLL_MFUN(hydra_get_int)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_int = h_obj->get_int();;
}

CK_DLL_MFUN(hydra_get_float)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_float = h_obj->get_float();;
}

CK_DLL_MFUN(hydra_get_bool)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_int = h_obj->get_bool();;
}

CK_DLL_MFUN(hydra_get_array)
{
  // NOTE: THIS DOESN't WORK YET
  // get our c++ class pointer
  Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);



  std::vector<Hydra*> vals = h_obj->get_array();

  t_CKINT size = vals.size();

  // allocate array object
  // Chuck_Array4 * range = new Chuck_Array4(TRUE, size);
    
  Chuck_DL_Api::Object obj = API->object->create(API, SHRED, API->object->get_type(API, SHRED, "int[]"));
  Chuck_Array4 * object = (Chuck_Array4 *) obj;
  std::vector<t_CKUINT> vec;
  object->m_vector = vec;
  // OBJ_MEMBER_INT(object, 
    



  // initialize with trappings of Object
  // initialize_object(range, SHRED->vm_ref->env()->ckt_array);
    

  // RETURN->v_object = h_obj->get_bool();
}

CK_DLL_MFUN(hydra_set_null)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);
    h_obj->set();
    RETURN->v_object = SELF;
}

CK_DLL_MFUN(hydra_set_config)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    Chuck_Object* config = GET_NEXT_OBJECT(ARGS);
    Hydra * h_config = (Hydra *) OBJ_MEMBER_INT(config, hydra_data_offset);
    h_obj->set(h_config->get_value());
    RETURN->v_object = SELF;
}

CK_DLL_MFUN(hydra_set_str)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    std::string val = GET_NEXT_STRING_SAFE(ARGS);
    h_obj->set(val);
    RETURN->v_object = SELF;
}

CK_DLL_MFUN(hydra_set_int)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    double val = GET_NEXT_INT(ARGS);
    h_obj->set(val);
    RETURN->v_object = SELF;
}

CK_DLL_MFUN(hydra_set_float)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    double val = GET_NEXT_FLOAT(ARGS);
    h_obj->set(val);
    RETURN->v_object = SELF;
}

CK_DLL_MFUN(hydra_set_true)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    h_obj->set(true);
    RETURN->v_object = SELF;
}

CK_DLL_MFUN(hydra_set_false)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    h_obj->set(false);
    RETURN->v_object = SELF;
}

CK_DLL_MFUN(hydra_is_null)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_int = h_obj->is_null();
}

CK_DLL_MFUN(hydra_is_config)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_int = h_obj->is_config();
}

CK_DLL_MFUN(hydra_is_str)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_int = h_obj->is_string();
}

CK_DLL_MFUN(hydra_is_number)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_int = h_obj->is_number();
}

CK_DLL_MFUN(hydra_is_bool)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_int = h_obj->is_bool();
}

CK_DLL_MFUN(hydra_is_array)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    RETURN->v_int = h_obj->is_array();
}


CK_DLL_MFUN(hydra_dir)
{
    // get our c++ class pointer
    Hydra * h_obj = (Hydra *) OBJ_MEMBER_INT(SELF, hydra_data_offset);

    std::string cwd = h_obj->dir();

    RETURN->v_string = (Chuck_String*)API->object->create_string(API, SHRED, cwd.c_str());
}
