// v158 arm K — the remaining contamination shapes.
package Kpk;
  class bolt0;
    static function bolt0 fit(string s); fit = new(); endfunction
  endclass
  class Edge0 #(type YY = int);
    // outer bad WITH locals, inner bad WITHOUT locals: the inner must stay
    // unlisted and MUST NOT inherit the outer's locals.
    function void outerHas0();
      begin : capA0
        YY ma0;
        string mb0;
        begin
          YY::fit("inner0");
        end
        ma0 = YY::fit("ma0");
        mb0 = "mb0";
      end : capA0
    endfunction
    // labelled bad block inside a labelled ACCEPTED block
    function void mixLbl0();
      begin : capB0
        int mc0;
        mc0 = 1;
        begin : capC0
          YY md0;
          md0 = YY::fit("md0");
        end : capC0
      end : capB0
    endfunction
    // FOREACH body (slang wraps foreach in an implicit block)
    task feach0();
      int bag0 [4];
      foreach (bag0[i0]) begin
        YY me0;
        me0 = YY::fit("me0");
      end
    endtask
    // bad block whose local shadows an outer local of the same name
    function void shadow0();
      begin : capD0
        int mf0;
        mf0 = 2;
        begin
          YY mf0;
          mf0 = YY::fit("mf0");
        end
      end : capD0
    endfunction
  endclass
  // NON-generic control with the identical shapes
  class Keep0;
    function void outerHas0();
      begin : capA0
        int ma0;
        string mb0;
        begin
          ma0 = 1;
        end
        mb0 = "mb0";
      end : capA0
    endfunction
    function void shadow0();
      begin : capD0
        int mf0;
        mf0 = 2;
        begin
          string mf0;
          mf0 = "x";
        end
      end : capD0
    endfunction
  endclass
endpackage
module wtop_k;
  Kpk::Keep0 k0;
  initial begin
    k0 = new();
    k0.outerHas0();
  end
endmodule
