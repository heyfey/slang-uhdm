// r10uvm190 arm C — THE ARM THAT TESTS RATHER THAN AGREES.
//
// Every cell here is deliberately built so that a WRONG law still produces a
// database that LOOKS right in arm A: the axes are declaration ORDER, name
// CASE, the number of enums SHARING one typedef, the number of typedefs
// sharing one parameter, a CHAINED typedef (which § enumBaseTdChainNoClone10
// says takes NO clone at all, so this pass must not reach it), and a typedef
// whose enum is declared BEFORE the parameter it reads is used elsewhere.
package pkc190;
  // c1 — THREE enums over ONE typedef: golden mints one clone per enum, so a
  // law that fixed only the first would leave two bound.
  parameter CW = 22;
  typedef bit [CW-1 : 0] tc_t;
  typedef enum tc_t { c1a = 0, c1b = 1 } e_c1;
  typedef enum tc_t { c2a = 0, c2b = 2 } e_c2;
  typedef enum tc_t { c3a = 0, c3b = 4 } e_c3;

  // c4 — the enum declared BEFORE another typedef over the same parameter
  typedef enum bit [CW-1 : 0] { c4a = 0, c4b = 1 } e_anon;  // no typedef name
  typedef bit [CW-1 : 0] tc2_t;
  typedef enum tc2_t { c5a = 0, c5b = 1 } e_c5;

  // c6 — a CHAINED typedef: § enumBaseTdChainNoClone10 binds the LISTING
  // object and mints no clone, so this pass must leave it exactly alone.
  typedef tc_t tc_chain_t;
  typedef enum tc_chain_t { c6a = 0, c6b = 1 } e_chain;

  // c7 — CASE: a parameter whose name differs from another only by case
  parameter cw = 9;
  typedef bit [cw-1 : 0] tlow_t;
  typedef enum tlow_t { c7a = 0, c7b = 1 } e_low;

  // c8 — a scalar (unranged) typedef base: no ranges at all
  typedef bit tsc_t;
  typedef enum tsc_t { c8a = 1'b0, c8b = 1'b1 } e_sc;

  // c9 — an int-atom typedef base
  typedef int ti_t;
  typedef enum ti_t { c9a = 0, c9b = 1 } e_int;
endpackage

module g190_c;
  pkc190::e_c1    x1;
  pkc190::e_c2    x2;
  pkc190::e_c3    x3;
  pkc190::e_anon  x4;
  pkc190::e_c5    x5;
  pkc190::e_chain x6;
  pkc190::e_low   x7;
  pkc190::e_sc    x8;
  pkc190::e_int   x9;
  initial begin
    x1 = pkc190::c1b; x2 = pkc190::c2b; x3 = pkc190::c3b;
    x4 = pkc190::c4b; x5 = pkc190::c5b; x6 = pkc190::c6b;
    x7 = pkc190::c7b; x8 = pkc190::c8b; x9 = pkc190::c9b;
  end
endmodule
