// r10uvm158 grid, arm D — LISTING COUNTS AND ORDER, and the two other things a
// block's scope carries: its LABEL and its block-scope PARAMETERS.
// 0 / 1 / 2 / 3 locals in a rejected block; a rejected block with a
// localparam; a rejected NAMED block with locals (the label + the fullname
// prefix of everything under it); a rejected block with NO locals at all (the
// unrecoverable face — there is no handle to the scope).
package pd158;

  class cntD158 #(type T = int);
    string sink158 = "";

    // ZERO locals, statement rejected: nothing to list, nothing to recover.
    function void zeroBad158();
      begin
        sink158 = T::type_id::create("z158");
      end
    endfunction

    function void oneBad158();
      begin
        T d1a158;
        d1a158 = T::type_id::create("d1158");
      end
    endfunction

    function void twoBad158();
      begin
        T d2a158;
        T d2b158;
        d2a158 = T::type_id::create("d2158");
      end
    endfunction

    function void threeBad158();
      begin
        T d3a158;
        int d3b158;
        string d3c158;
        d3a158 = T::type_id::create("d3158");
      end
    endfunction

    // a rejected block that also declares a block-scope localparam.
    function void paramBad158();
      begin
        localparam int DP158 = 5;
        T dpv158;
        dpv158 = T::type_id::create("dp158");
      end
    endfunction

    // a rejected NAMED block with locals: the label, the end label, and the
    // `::lb158::` prefix every local's vpiFullName takes.
    function void namedBad158();
      begin : lb158
        T dna158;
        int dnb158;
        dna158 = T::type_id::create("dn158");
      end : lb158
    endfunction

    // a rejected NAMED block with NO locals — no handle, no recovery.
    function void namedZero158();
      begin : lz158
        sink158 = T::type_id::create("lz158");
      end
    endfunction

    // TWO sibling rejected blocks in one body, so the order of the whole
    // listing is visible.
    function void twinBad158();
      begin
        T dta158;
        dta158 = T::type_id::create("dt1158");
      end
      begin
        T dtb158;
        dtb158 = T::type_id::create("dt2158");
      end
    endfunction
  endclass

endpackage

module topd158;
  initial begin
    $display("d158");
  end
endmodule
