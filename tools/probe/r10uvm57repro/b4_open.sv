// r10uvm57repro/b4_open.sv -- the cells the DEPTH-EQUALITY reading leaves open,
// measured BEFORE any emitter change so the patch is informed, not assumed.
// NOTE the class split: Surelog reports CP0332 ("Function sink is not defined
// for variable this") for an UNQUALIFIED package-function call inside a class
// that EXTENDS another, so every cell except the deliberate `super.` one lives
// in a NON-derived class.  Measuring them in one derived class would have made
// the golden an error recovery, not a golden.
package pb4;
  function automatic void sink(string s); $display(s); endfunction
  function automatic int wrap(string s); return 1; endfunction
  function automatic string str8(int i); return "z"; endfunction

  class base4;
    function void bm(string s); endfunction
    function int bm2(string s); return 1; endfunction
    virtual function void vm(string s); endfunction
  endclass

  class shp;                          // NOT derived
    base4 o;
    // E1: PLAIN begin at method top level (depth 0), local read one control
    //     body deeper -- the depth law says BARE, "any unnamed block" says BIND.
    //     REFUTATION RECORDED: a PACKAGE-function call from inside a nested
    //     block of a class method makes Surelog emit CP0332 ("Function sink is
    //     not defined for variable this") and recover, so this cell uses an
    //     unqualified SIBLING CLASS METHOD call instead -- which is also a new
    //     cell in its own right (b1/b2/b3 only ever called package functions).
    function int e1(int obj);
      e1 = obj;
      begin
        string p0;
        p0 = "p";
        im(p0);                // depth 0 == decl depth 0, SIBLING METHOD call
        if (obj == 0) begin
          im(p0);              // depth 1 != decl depth 0
        end
      end
    endfunction
    // E1b: the same two depths with a sibling-method call, control body outer
    function int e1b(int obj);
      e1b = obj;
      if (obj == 0) begin
        string q0;
        q0 = "q";
        im(q0);                // depth 1 == decl depth 1
        sink(q0);              // depth 1 == decl depth 1, PACKAGE call
        if (obj == 0) begin
          im(q0);              // depth 2 != decl depth 1
        end
      end
    endfunction
    // E2: RECEIVER-QUALIFIED call, statement and expression position
    function int e2(int obj);
      e2 = obj;
      if (obj == 0) begin
        string r2;
        r2 = "r";
        o.bm(r2);                    // STATEMENT position, direct receiver
        e2 = wrap(r2) + o.bm2(r2);   // EXPRESSION position, direct receiver
      end
    endfunction
    // E4: this.<m>(arg), statement position
    function int e4(int obj);
      e4 = obj;
      if (obj == 0) begin
        string t4;
        t4 = "t";
        this.im(t4);
      end
    endfunction
    function void im(string s); endfunction
    // E5: TASK call argument
    task e5(int obj);
      if (obj == 0) begin
        string k5;
        k5 = "k";
        tsk5(k5);
      end
    endtask
    task tsk5(string s); endtask
    // E6: VIRTUAL method
    virtual function int e6(int obj);
      e6 = obj;
      if (obj == 0) begin
        string v6;
        v6 = "v";
        sink(v6);
      end
    endfunction
    // E7: return expression
    function int e7(int obj);
      if (obj == 0) begin
        string n7;
        n7 = "n";
        sink(n7);
        return wrap(n7);
      end
      return obj;
    endfunction
    // E8: ref nested TWO calls deep
    function int e8(int obj);
      e8 = obj;
      if (obj == 0) begin
        string n8;
        n8 = "n";
        e8 = wrap(str8(wrap(n8)));
        sink(n8);
      end
    endfunction
    // E9: fork arm INSIDE an if body
    task e9(int obj);
      if (obj == 0) begin
        string f9;
        f9 = "f";
        sink(f9);
        fork
          begin
            string g9;
            g9 = "g";
            sink(g9);             // fork-arm block local, fork inside an if
            sink(f9);             // if-body local read from the fork arm
          end
        join
      end
    endtask
  endclass

  // E3: super.<m>(arg) -- the ONLY derived class here, on purpose (see header)
  class der4 extends base4;
    function int e3(int obj);
      e3 = obj;
      if (obj == 0) begin
        string s3;
        s3 = "s";
        super.bm(s3);
        bm(s3);                   // unqualified INHERITED method, same block
      end
    endfunction
  endclass
endpackage

module b4_open;
  int q;
  initial q = 0;
  pb4::shp sh;
  pb4::der4 dr;
  initial sh = null;
  initial dr = null;
endmodule
