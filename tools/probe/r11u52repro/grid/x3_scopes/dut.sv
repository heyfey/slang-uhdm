// r11u52 ROAD C — SCOPES other than the module body: a FUNCTION body, a TASK
// body and a named BEGIN block each declare the same unpacked-dim typedef.
// These are NOT CompileModule.cpp:653/:1130; the arm measures whether the
// producer's hard Reduce::No reaches them.
module dut #(parameter int unsigned NDATA = 2, parameter int unsigned DEPTH = 4)
           (output logic [NDATA-1:0] o);
  typedef logic [NDATA-1:0] body_t [DEPTH];   // module body (the law's site)
  body_t bm;
  function automatic logic [NDATA-1:0] f();
    typedef logic [NDATA-1:0] fn_t [DEPTH];   // FUNCTION body
    fn_t lv;
    return lv[0];
  endfunction
  task automatic t(output logic [NDATA-1:0] r);
    typedef logic [NDATA-1:0] tk_t [DEPTH];   // TASK body
    tk_t lv;
    r = lv[0];
  endtask
  logic [NDATA-1:0] tv;
  always_comb begin : blk
    typedef logic [NDATA-1:0] bk_t [DEPTH];   // named BEGIN block
    bk_t lv;
    tv = lv[0];
  end
  assign o = bm[0] | f() | tv;
endmodule
