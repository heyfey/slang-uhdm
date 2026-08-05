// t28 — a package typedef whose packed RANGE BOUND is an EXPRESSION, seen
// from every view.  UVM's `typedef bit [`UVM_REG_DATA_WIDTH-1:0]
// uvm_reg_data_t;` (a macro literal minus one) and `typedef logic
// [UVM_HDL_MAX_WIDTH-1:0] uvm_hdl_data_t;` (a parameter minus one) are the two
// shapes; the question is which VIEWS keep the operation and which fold it.
`define MW 64

package p28;

  parameter int PW = 8;

  typedef bit unsigned [`MW-1:0] mt;   // macro literal minus one
  typedef logic [PW-1:0]         pt;   // parameter minus one

  // free package function: formal, local and return all carry the typedefs
  function mt free28(mt fa, pt fb);
    mt loc_m;
    pt loc_p;
    loc_m = fa;
    loc_p = fb;
    return loc_m;
  endfunction

  class C28;
    mt prop_m;
    function mt m28(mt ma, pt mb);
      mt mloc_m;
      pt mloc_p;
      mloc_m = ma;
      mloc_p = mb;
      return mloc_m;
    endfunction
  endclass

endpackage : p28

package q28;
  import p28::*;
  function mt q28f(mt qa);
    mt qloc;
    qloc = qa;
    return qloc;
  endfunction
endpackage : q28

module top28;
  import p28::*;
  mt modvar_m;
  pt modvar_p;
  function mt mod28(mt xa);
    mt xloc;
    xloc = xa;
    return xloc;
  endfunction
  initial begin
    modvar_m = mod28(1);
  end
endmodule
