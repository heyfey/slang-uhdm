// r10uvm167 grid, arm A — THE CORE.  Is a call's vpiArgument list the WRITTEN
// actuals, on both sides of the bad-expression SHELL?
//
// THE SHELL TRIGGER, and it is the corpus's own: an argument that reads through
// a `<type parameter>::<name>` qualifier inside a GENERIC class's DEFAULT
// specialization.  The default is `int`, slang looks the name up in `int`,
// finds nothing and returns `badExpr` — which wraps the WHOLE call
// (`CallExpression::fromArgs:318`), and the wrapper, not the call, is the
// object `Expression::create` stamps the invocation syntax on.  Surelog binds
// nothing through `::` at all and compiles the call exactly as it compiles a
// clean one, which is what makes every `sh*` / `cl*` pair below a controlled
// comparison: SAME call, SAME callee, SAME written arguments, only the shell
// differs.
//
// uvm-1.2 `base/uvm_misc.svh:720` — `comp.uvm_report_fatal("GET_CFG_TYPE_FAIL",
// {..., TYPE::type_name, ...}, UVM_NONE, `uvm_file, `uvm_line)` inside
// `uvm_utils#(TYPE,FIELD)::get_config` — IS the `sh_meth5` cell.
package ap167;

  class Rcv167;
    // five formals, TWO with defaults: the corpus callee's shape
    virtual function void rf167(string id, string msg, int verb = 0,
                                string fn = "", int ln = 0);
    endfunction
    // two trailing defaults on a TASK
    virtual task rt167(int a, int b = 7, string c = "z");
    endtask
    // a MIDDLE default with a later formal
    function int mid167(int a, int b = 3, int c = 0);
      return a + b + c;
    endfunction
    // ALL formals defaulted
    function int all167(int a = 1, int b = 2);
      return a + b;
    endfunction
    function int none167();
      return 5;
    endfunction
    static function int st167(int a, int b = 4);
      return a + b;
    endfunction
  endclass

  class Base167;
    int bx;
    function new(int a = 1, string b = "d");
      bx = a;
    endfunction
    virtual function int vm167(int a, int b = 6);
      return a + b;
    endfunction
  endclass

  // ---------------------------------------------------------------- SHELLED
  // Every call here carries ONE extra written argument that reads through
  // `T167::`, so slang wraps the call and only the shell holds the syntax.
  class Gsh167 #(type T167 = int, string FLD167 = "cfg") extends Base167;

    static function int sh_meth5(Rcv167 comp);
      // THE CORPUS CELL: 5 formals, 5 written, 2 of them defaulted-away
      comp.rf167("ID", {"a ", T167::type_name}, 0, "f.sv", 42);
      // 5 formals, 3 written -> golden lists THREE
      comp.rf167("ID2", {"b ", T167::type_name}, 1);
      // 5 formals, 2 written -> golden lists TWO
      comp.rf167("ID3", T167::type_name);
      return 0;
    endfunction

    static task sh_task(Rcv167 comp);
      // TASK, 3 formals, 1 written + the shell argument
      comp.rt167(T167::type_name);
      // TASK, 3 formals, 2 written
      comp.rt167(3, T167::type_name);
    endtask

    static function int sh_mid(Rcv167 comp);
      int r;
      // MIDDLE default via NAMED association, a later formal written
      r = comp.mid167(.a(T167::type_name), .c(9));
      // NAMED, reordered
      r = r + comp.mid167(.c(T167::type_name), .a(1));
      return r;
    endfunction

    static function int sh_all(Rcv167 comp);
      int r;
      // ALL formals defaulted, EMPTY PARENS, shelled by a sibling call
      r = comp.all167() + comp.mid167(T167::type_name);
      // one written of two defaulted formals
      r = r + comp.all167(T167::type_name);
      return r;
    endfunction

    static function int sh_empty(Rcv167 comp);
      // a WRITTEN-BUT-EMPTY positional slot inside a shell
      return comp.mid167(T167::type_name, , 4);
    endfunction

    static function int sh_static();
      // a STATIC method call through the class name
      return Rcv167::st167(T167::type_name);
    endfunction

    function int sh_this(int q);
      // THIS-rooted, and a SUPER-rooted call, both shelled
      return this.vm167(T167::type_name) + super.vm167(T167::type_name);
    endfunction

    static function Base167 sh_new();
      Base167 h;
      // a CONSTRUCTOR with trailing defaults, shelled
      h = new(T167::type_name);
      return h;
    endfunction

    static function int sh_eqdef(Rcv167 comp);
      // WRITTEN ARGUMENTS THAT ARE TEXTUALLY EQUAL TO THEIR DEFAULTS — these
      // must STAY.  mid167's defaults are 3 and 0; all167's are 1 and 2.
      return comp.mid167(T167::type_name, 3, 0) + comp.all167(1, 2);
    endfunction
  endclass

  // ------------------------------------------------------------ NOT SHELLED
  // The identical calls with a bindable argument in place of the `T167::` one.
  // These are the pass's MUST-NOT-MOVE floor: they already list the written
  // arguments today and must be byte-identical after the change.
  class Gcl167 #(type T167 = int, string FLD167 = "cfg") extends Base167;

    static function int cl_meth5(Rcv167 comp);
      comp.rf167("ID", {"a ", FLD167}, 0, "f.sv", 42);
      comp.rf167("ID2", {"b ", FLD167}, 1);
      comp.rf167("ID3", FLD167);
      return 0;
    endfunction

    static task cl_task(Rcv167 comp);
      comp.rt167(1);
      comp.rt167(3, 2);
    endtask

    static function int cl_mid(Rcv167 comp);
      int r;
      r = comp.mid167(.a(1), .c(9));
      r = r + comp.mid167(.c(2), .a(1));
      return r;
    endfunction

    static function int cl_all(Rcv167 comp);
      int r;
      r = comp.all167() + comp.mid167(1);
      r = r + comp.all167(2);
      return r;
    endfunction

    static function int cl_empty(Rcv167 comp);
      return comp.mid167(1, , 4);
    endfunction

    static function int cl_static();
      return Rcv167::st167(1);
    endfunction

    function int cl_this(int q);
      return this.vm167(q) + super.vm167(q);
    endfunction

    static function Base167 cl_new();
      Base167 h;
      h = new(2);
      return h;
    endfunction

    static function int cl_eqdef(Rcv167 comp);
      return comp.mid167(1, 3, 0) + comp.all167(1, 2);
    endfunction
  endclass

endpackage
