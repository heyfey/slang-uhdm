// r10buvm26 grid — assignments whose RHS (or LHS) is a METHOD CALL on an
// INDEXED / SELECTED receiver.  MEASUREMENT ONLY.
// Shapes mirror uvm_pkg.sv:45158  `list[name] = list1[name].get_comp();`

package p26;

  class leaf26;
    int v;
    function int gv(); return v; endfunction
    function int gv1(int k); return v + k; endfunction
    function leaf26 self(); return this; endfunction
  endclass

  class mid26;
    leaf26 lf;
    function leaf26 gl(); return lf; endfunction
  endclass

  // ---- a1: class, IN-BODY method, assoc(string) receiver -----------------
  class a1_26;
    leaf26 as26[string];
    int    ai26[string];
    int    fx26[4];
    int    qu26[$];
    int    dy26[];
    mid26  am26[string];
    leaf26 h26;
    int    sc26;

    // C1 a[k] = b[k].m();        assoc/assoc
    function void c1(string k); ai26[k] = as26[k].gv(); endfunction
    // C2 a[k] = b.m();           handle receiver
    function void c2(string k); ai26[k] = h26.gv(); endfunction
    // C3 a = b[k].m();           scalar lhs
    function void c3(string k); sc26 = as26[k].gv(); endfunction
    // C4 a[k] = b[k].c.m();      indexed then member then call
    function void c4(string k); ai26[k] = am26[k].lf.gv(); endfunction
    // C5 a[k] = b[k].m(x);       call WITH an argument
    function void c5(string k, int x); ai26[k] = as26[k].gv1(x); endfunction
    // C6 a[k].n = b[k].m();      LHS is a member of a select
    function void c6(string k); as26[k].v = as26[k].gv(); endfunction
    // C7 a[k] = b[k].m().n;      member OF a call result
    function void c7(string k); ai26[k] = as26[k].self().v; endfunction
    // C8 +=
    function void c8(string k); ai26[k] += as26[k].gv(); endfunction
    // C9 queue receiver
    function void c9(int i); qu26[i] = as26["z"].gv(); endfunction
    // C10 dynamic-array receiver
    function void c10(int i); dy26[i] = as26["z"].gv(); endfunction
    // C11 fixed unpacked receiver
    function void c11(int i); fx26[i] = as26["z"].gv(); endfunction
    // C12 receiver is a QUEUE of handles
    leaf26 qh26[$];
    function void c12(int i); ai26["z"] = qh26[i].gv(); endfunction
    // C13 receiver is a DYNAMIC array of handles
    leaf26 dh26[];
    function void c13(int i); ai26["z"] = dh26[i].gv(); endfunction
    // C14 receiver is a FIXED array of handles
    leaf26 fh26[4];
    function void c14(int i); ai26["z"] = fh26[i].gv(); endfunction
    // C15 statement-position call on an indexed receiver (buvm23 control)
    function void c15(int i); void'(fh26[i].gv()); endfunction
    // C16 no-paren method reference
    function void c16(int i); ai26["z"] = fh26[i].gv(); endfunction
    // C17 the exact uvm shape: ref formal assoc LHS, assoc handle RHS
    function void c17(ref int lst[string]);
      foreach (as26[nm]) begin
        lst[nm] = as26[nm].gv();
      end
    endfunction
    // C18 chained index then index then call
    leaf26 aa26[string][string];
    function void c18(string k); ai26[k] = aa26[k][k].gv(); endfunction
    // OOB declaration
    extern function void c19(string k);
  endclass

  function void a1_26::c19(string k); ai26[k] = as26[k].gv(); endfunction

  // ---- a2: PACKAGE-level function ---------------------------------------
  leaf26 pas26[string];
  int    pai26[string];
  leaf26 pqh26[$];

  function void pf26(string k);
    pai26[k] = pas26[k].gv();
  endfunction

  function void pf26b(int i);
    pai26["z"] = pqh26[i].gv();
  endfunction

  task pt26(string k);
    pai26[k] = pas26[k].gv();
  endtask

endpackage

// ---- a3: MODULE initial / always, non-blocking ---------------------------
module m26;
  import p26::*;
  leaf26 mh26[string];
  leaf26 mq26[$];
  int    mi26[string];
  int    mr26;
  logic [7:0] mv26;

  initial begin
    mi26["a"] = mh26["a"].gv();       // D1 assoc handle in a module initial
    mr26      = mq26[0].gv();         // D2 queue handle
  end

  always_comb begin
    mr26 = mh26["b"].gv();            // D3
  end

  initial begin
    mv26 <= mq26[1].gv();             // D4 non-blocking
  end

  // D5 in a module task
  task automatic mt26(int i);
    mi26["c"] = mq26[i].gv();
  endtask

  // D6 two instances of a generic wrapper
  w26 #(2) u0();
  w26 #(3) u1();
endmodule

module w26 #(parameter int N = 1);
  import p26::*;
  leaf26 wh26[string];
  int    wi26[string];
  initial wi26["k"] = wh26["k"].gv();
endmodule
