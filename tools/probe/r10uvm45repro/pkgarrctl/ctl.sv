// r10uvm45 — POSITIVE CONTROL for pkgarr.py.  A census that reports ZERO is
// indistinguishable from a census that cannot see anything, so the corrected
// script must find every line below and must NOT report the two struct members
// (the exact false-positive mode the first version had) or the three dimension
// spellings emitPkgArrayVar already accepts.
package pkgarrctl;
  // MUST BE FOUND — fixed-size unpacked array VARIABLES at package scope.
  int          hit_lit[8];
  logic [7:0]  hit_range[0:3];
  bit          hit_expr[4'd2];
  string       hit_const[SIZE];        // AMBIG: constant size or assoc index

  // MUST NOT BE FOUND — already-handled dimension spellings.
  int          no_queue[$];
  int          no_dyn[];
  int          no_assoc[string];
  int          no_assoc_td[my_key_t];

  // MUST NOT BE FOUND — struct MEMBERS, a different emitter path entirely.
  typedef struct {
    logic [31:0] no_member_pair[2];
    bit   [31:0] no_member_keys[8];
  } s_t;

  // MUST NOT BE FOUND — not variables.
  typedef int no_td_array[4];
  parameter int no_param[2] = '{1, 2};
endpackage
