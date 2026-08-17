// r10uvm80 VERIFIER arm v5 — EDGE SHAPES the c1/c2/v1..v4 grids do not reach.
// Multi-declarator with MIXED dimensions (one scalar + one array in the same
// declaration, so ONE keyword must reach TWO different factories), a virtual
// class method, a nested class, a class extended from another, an assertion
// ACTION BLOCK, a task instantiated TWICE through an instance array (the same
// StatementBlockSymbol emitted twice), an `automatic` inside a `disable fork`
// region, and a declaration whose type is a class PARAMETERIZED by a typedef.
package pv5;
  typedef struct { int a; } sv5_t;

  class base5;
    int b_i;
    virtual task t_virt();
      begin
        automatic int e_vtauto = 1;      // e1  virtual method begin, kw
        int           e_vtplain = 2;     // e2  virtual method begin, NO kw
        b_i = e_vtauto + e_vtplain;
      end
    endtask
  endclass

  class der5 extends base5;
    virtual task t_virt();
      begin
        automatic int e_ovauto = 3;      // e3  OVERRIDE method begin, kw
        b_i = e_ovauto;
      end
    endtask
  endclass

  class outer5;
    int o_i;
    // (forward class typedef removed: slang rejects the unused forward decl)
    task t_multi();
      begin
        // ONE `automatic` keyword, TWO declarators, DIFFERENT factories:
        // a scalar (site 4) and a fixed unpacked array (site 3).
        automatic int e_ms = 1, e_ma [3];        // e4/e5 mixed multi-declarator
        // ONE keyword, a scalar and a QUEUE (site 4 + site 1).
        automatic int e_qs = 2, e_qq [$];        // e6/e7
        // ONE keyword, a struct and an assoc (site 4 + site 2).
        automatic sv5_t e_st, e_as [string];     // e8/e9
        // controls, no keyword, same shapes
        int   e_cs = 3, e_ca [3];                // e10/e11
        o_i = e_ms + e_ma[0] + e_qs + e_st.a + e_as["k"].a + e_cs + e_ca[0];
        e_qq.push_back(1);
        o_i += e_qq.size();
      end
    endtask
  endclass

  class inner5;
    int i_i;
    task t_in();
      begin
        automatic int e_inauto = 1;      // e12 nested-class method begin, kw
        i_i = e_inauto;
      end
    endtask
  endclass
endpackage

interface iv5;
  logic clk, req, ack;
  int   ii;
  // assertion ACTION BLOCK — a begin with its own declaration
  always @(posedge clk) begin
    automatic int e_alauto = 1;          // e13 interface always begin, kw
    ii = e_alauto;
  end
endinterface

module mv5sub;
  int si;
  task t_sub();
    begin
      automatic int e_subauto = 1;       // e14 task in an INSTANCE-ARRAY module
      int           e_subplain = 2;      // e15 same, NO kw
      si = e_subauto + e_subplain;
    end
  endtask
  initial t_sub();
endmodule

module mv5;
  logic clk = 0;
  int mi;
  // the same module body elaborated TWICE (instance array)
  mv5sub u5 [2] ();
  iv5    i5 ();
  initial begin
    automatic int e_topauto = 1;         // e16 top initial, kw
    // `disable fork` region
    fork
      begin
        automatic int e_dfauto = 2;      // e17 fork arm begin under disable fork
        mi = e_dfauto;
      end
    join_none
    disable fork;
    mi += e_topauto;
  end
  // assertion with an action block carrying a declaration
  property p5; @(posedge clk) i5.req |-> ##1 i5.ack; endproperty
  a5: assert property (p5) begin
        automatic int e_aaauto = 1;      // e18 assert ACTION block, kw
        mi = e_aaauto;
      end
      else begin
        automatic int e_abauto = 2;      // e19 assert ELSE action block, kw
        mi = e_abauto;
      end
endmodule
