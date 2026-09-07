// r10uvm190 arm B — WHERE THE TYPEDEF AND ITS ENUM LIVE, and THE OTHER CLONE
// POSITIONS THAT MUST NOT MOVE.
//
// The same ranged typedef with a parameter bound is declared in a PACKAGE, a
// MODULE, a CLASS and the compilation unit, and in each home an enum takes it
// as its base.  The same typedef is ALSO used at the clone positions earlier
// passes own — a function FORMAL, a function RETURN, a body LOCAL, an unpacked
// ARRAY ELEMENT and a plain variable declaration — so an over-wide version of
// this law would show up here as a moved cell that this pass did not claim.
package pkb190;
  parameter BW = 24;
  typedef bit [BW-1 : 0] tb_t;
  typedef enum tb_t { b1_0 = 0, b1_1 = 1 } eb_pkg;   // b1 package home

  // the OTHER clone positions of the very same typedef
  function automatic tb_t fb(input tb_t arg);        // b5 formal + b6 return
    tb_t loc;                                        // b7 body local
    loc = arg;
    return loc;
  endfunction
  tb_t elems [4];                                    // b8 unpacked array elem
  tb_t plain;                                        // b9 plain variable
endpackage

module g190_b;
  parameter MW = 18;
  typedef bit [MW-1 : 0] tm_t;
  typedef enum tm_t { b2_0 = 0, b2_1 = 1 } eb_mod;   // b2 module home

  class C190;
    localparam CW = 14;
    typedef bit [CW-1 : 0] tc_t;
    typedef enum tc_t { b3_0 = 0, b3_1 = 1 } eb_cls; // b3 class home
    tc_t cv;
  endclass

  pkb190::eb_pkg u1;
  eb_mod         u2;
  C190           u3;
  pkb190::tb_t   u4;
  initial begin
    u1 = pkb190::b1_1;
    u2 = b2_1;
    u4 = pkb190::fb(pkb190::tb_t'(3));
  end
endmodule
