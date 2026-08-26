// v158 arm H — SCOPE CROSS-CONTAMINATION TRAPS.
// Each cell asks: can the recovery attach the WRONG block's scope?
package Tpk;
  class pin2;
    static function pin2 drive(string s); drive = new(); endfunction
  endclass

  class Trap2 #(type WW = int);
    // (1) NAMED outer WITH locals, holding a rejected inner WITH locals.
    function void nestBoth2();
      begin : outer2
        WW oa2;
        begin
          WW ib2;
          ib2 = WW::drive("ib2");
        end
        oa2 = WW::drive("oa2");
      end : outer2
    endfunction
    // (2) NAMED outer with NO locals, holding a rejected inner WITH locals.
    //     The unsound recovery (child scope's parent) would stamp `edge2`
    //     on the INNER block.  It must not.
    function void nestOuterBare2();
      begin : edge2
        begin
          WW ic2;
          ic2 = WW::drive("ic2");
        end
      end : edge2
    endfunction
    // (3) Two rejected siblings with DIFFERENT locals, same shape.
    function void sibs2();
      if (1) begin
        WW pa2;
        pa2 = WW::drive("pa2");
      end
      if (1) begin
        WW pb2;
        string pc2;
        pb2 = WW::drive("pb2");
        pc2 = "pc2";
      end
    endfunction
    // (4) An ACCEPTED block immediately after a rejected one, same method.
    function void mixed2();
      if (1) begin
        WW qa2;
        qa2 = WW::drive("qa2");
      end
      if (1) begin
        int qb2;
        qb2 = 11;
      end
    endfunction
    // (5) rejected block inside a FOR body inside a rejected block
    task deep2();
      if (1) begin
        WW ra2;
        for (int j2 = 0; j2 < 2; j2++) begin
          WW rb2;
          rb2 = WW::drive("rb2");
        end
        ra2 = WW::drive("ra2");
      end
    endtask
  endclass

  // NON-generic control class, identical shapes, must stay byte-identical.
  class Keep2;
    function void nestBoth2();
      begin : outer2
        int oa2;
        begin
          int ib2;
          ib2 = 1;
        end
        oa2 = 2;
      end : outer2
    endfunction
    function void nestOuterBare2();
      begin : edge2
        begin
          int ic2;
          ic2 = 3;
        end
      end : edge2
    endfunction
  endclass
endpackage

module wtop_h;
  Tpk::Keep2 k2;
  initial begin
    k2 = new();
    k2.nestBoth2();
  end
endmodule
