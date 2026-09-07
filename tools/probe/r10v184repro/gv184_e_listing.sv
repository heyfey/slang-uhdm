// r10v184 VERIFIER ARM E — THE LISTING FACES the verifier brief names, held
// against § tfItemLocalAutomaticIsNotWrittenStatic139's PRODUCTION law.
//
// The r10uvm184 brief framed the head as a LISTING miss ("golden lists the
// static string declaration as a variable of its enclosing begin block").  The
// implementer refuted that framing and landed a BINDING law instead.  This arm
// exists to prove the LISTING law does not regress underneath it: every face
// the brief enumerates is present here and must read the same on the pristine
// and the patched binary, and must not lose ground against one real Surelog
// golden.
//   * STATIC vs AUTOMATIC locals, INITIALIZED vs BARE statics
//   * each declared kind: int / string / class HANDLE / UNPACKED ARRAY / struct
//   * FUNCTION-level vs BEGIN-level vs NAMED-begin vs NESTED-begin
//   * a static in a TASK vs a FUNCTION vs a CLASS METHOD
//   * MULTIPLE statics in one begin, in declaration ORDER
//   * the HOME listing vs a WILDCARD clone vs an EXPLICIT-import clone
// Names, numbers and orders are deliberately unlike the corpus'.
package Cornice405;

  typedef struct packed { bit [3:0] flute; bit [3:0] reed; } moulding_t;

  class Console405;
    int m_corbel;
    function new(); m_corbel = 2; endfunction
  endclass

  function automatic int soffit405(input int fml_s);
    // FUNCTION level, every kind, static and automatic, initialized and bare
    static    int        fl_stat_init = 3;
    static    int        fl_stat_bare;
    automatic int        fl_auto;
    static    string     fl_sstr_init = "corniceplaster";
    static    string     fl_sstr_bare;
    automatic string     fl_astr;
    static    Console405 fl_shandle;
    automatic Console405 fl_ahandle;
    static    int        fl_sarr[3];
    automatic int        fl_aarr[3];
    static    moulding_t fl_sstruct;
    automatic moulding_t fl_astruct;
    int acc;
    fl_stat_bare = 4;
    fl_auto      = 5;
    fl_sstr_bare = "dentil";
    fl_astr      = "volute";
    fl_shandle   = new();
    fl_ahandle   = new();
    fl_sarr[0]   = 6;
    fl_aarr[0]   = 7;
    fl_sstruct   = '{flute: 4'd1, reed: 4'd2};
    fl_astruct   = '{flute: 4'd3, reed: 4'd4};
    acc = fl_stat_init + fl_stat_bare + fl_auto + fl_sstr_init.len() +
          fl_sstr_bare.len() + fl_astr.len() + fl_shandle.m_corbel +
          fl_ahandle.m_corbel + fl_sarr[0] + fl_aarr[0] +
          int'(fl_sstruct.flute) + int'(fl_astruct.reed) + fml_s;
    begin : abacus405
      // MULTIPLE statics in ONE named begin, in declaration order
      static int        nb_first  = 8;
      static int        nb_second = 9;
      static int        nb_third;
      static string     nb_str    = "abacusband";
      automatic int     nb_auto;
      static Console405 nb_handle;
      static int        nb_arr[2];
      nb_third  = 10;
      nb_auto   = 11;
      nb_handle = new();
      nb_arr[0] = 12;
      acc += nb_first + nb_second + nb_third + nb_str.len() + nb_auto +
             nb_handle.m_corbel + nb_arr[0];
      begin
        // NESTED bare begin
        static int    deep_stat = 13;
        automatic int deep_auto;
        deep_auto = 14;
        acc += deep_stat + deep_auto;
      end
    end
    return acc;
  endfunction

  task automatic dentil405(input int fml_d, output int done405);
    static    int    tk_stat = 15;
    automatic int    tk_auto;
    static    string tk_str = "dentilcourse";
    tk_auto = 16;
    done405 = tk_stat + tk_auto + tk_str.len() + fml_d;
  endtask

  class Plinth405;
    int m_base;
    extern function int scotia405(input int fml_p);
    function int inbody405(input int fml_q);
      static    int    ib_stat = 17;
      automatic int    ib_auto;
      static    string ib_str = "inbodybead";
      ib_auto = 18;
      return ib_stat + ib_auto + ib_str.len() + fml_q + m_base;
    endfunction
  endclass

  function int Plinth405::scotia405(input int fml_p);
    static    int        oob_stat = 19;
    automatic int        oob_auto;
    static    string     oob_str = "scotiafillet";
    static    Console405 oob_handle;
    static    int        oob_arr[2];
    oob_auto   = 20;
    oob_handle = new();
    oob_arr[0] = 21;
    return oob_stat + oob_auto + oob_str.len() + oob_handle.m_corbel +
           oob_arr[0] + fml_p + m_base;
  endfunction

endpackage

// WILDCARD import — the clone listing
package Astragal405;
  import Cornice405::*;
  int seen_astragal405 = 22;
  function automatic int use_astragal405();
    Plinth405 pl;
    pl = new();
    return soffit405(2) + pl.scotia405(3) + pl.inbody405(4);
  endfunction
  task automatic run_astragal405(output int got405);
    int out405;
    dentil405(1, out405);
    got405 = out405 + use_astragal405();
  endtask
endpackage

// EXPLICIT named import — a different copy path
package Ovolo405;
  import Cornice405::soffit405;
  int seen_ovolo405 = 23;
  function automatic int use_ovolo405();
    return soffit405(5);
  endfunction
endpackage

module top405;
  import Astragal405::*;
  import Ovolo405::*;
  int tally405;
  initial begin
    run_astragal405(tally405);
    tally405 = tally405 + use_ovolo405();
    $display("%0d", tally405);
  end
endmodule
