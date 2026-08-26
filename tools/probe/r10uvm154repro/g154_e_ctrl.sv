// r10uvm154 arm E — the MUST-STAY controls, the arm that would catch an
// over-fire.  Nothing here is a unary minus over a bare decimal literal, and
// every constant must come out of the patched binary byte-identical to the
// pristine one.
//
//   * the SECOND negative-valued enum the corpus actually holds --
//     uvm-1.2's `uvm_tlm_response_status_e`, whose five members are written
//     `-1 .. -5` under NO base and which our pristine binary ALREADY valued
//     `INT:-N` / `-N` / 64 (census: 126 cells, all in the SAME set).  It is
//     reproduced here verbatim in shape so a regression on it is visible in
//     one arm rather than only in a UVM row;
//   * the based / sized / unbased-unsized literal encodings other passes own
//     (§ enumSubstIntConst30's INT: prefix, § enumCastInitNotEvaluated's
//     INT:0 cast rule, the `'0` unsized marker);
//   * the implicit-successor chain, whose counter is Surelog's `val` and not
//     this law's business;
//   * a computed concat init, which keeps the concat's own width.
package pk_e154;
   parameter int E_PARAM = 6;

   // The corpus's other negative-init enum -- must not move.
   typedef enum {
      TLM_OK        = 0,
      TLM_INCOMPLETE = 1,
      TLM_GENERIC   = -1,
      TLM_ADDRESS   = -2,
      TLM_COMMAND   = -3,
      TLM_BURST     = -4,
      TLM_BYTEEN    = -5
   } tlm_status_e;

   typedef enum bit [31:0] {
      HEX_SIZED   = 32'hFFFF_FFFF,
      HEX_UNSIZED = 'h5,
      BIN_SIZED   = 32'b1010,
      OCT_SIZED   = 32'o17,
      DEC_SIZED   = 32'd6
   } lit_e;

   typedef enum bit [3:0] {
      SUCC_BASE = 4'd2,
      SUCC_NEXT,
      SUCC_LAST
   } succ_e;

   typedef enum bit [3:0] { CAT_ONE = {2'b10, 2'b01}, CAT_TWO = 4'd3 } cat_e;
   typedef enum int       { REF_ONE = E_PARAM, REF_TWO = E_PARAM + 1 } ref_e;
   typedef enum bit [3:0] { UNS_ZERO = '0, UNS_ONE = 4'd1 } unsz_e;
endpackage

module top_e154;
   pk_e154::tlm_status_e t;
   pk_e154::lit_e        l;
   pk_e154::succ_e       s;
   pk_e154::cat_e        c;
   pk_e154::ref_e        r;
   pk_e154::unsz_e       u;
   initial begin
      t = pk_e154::TLM_GENERIC;
      l = pk_e154::HEX_SIZED;
      s = pk_e154::SUCC_NEXT;
      c = pk_e154::CAT_ONE;
      r = pk_e154::REF_ONE;
      u = pk_e154::UNS_ZERO;
   end
endmodule
