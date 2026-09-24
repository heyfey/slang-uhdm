// r10uvm57repro/b3_bound.sv -- PIN THE PREDICATE.  b2 left two readings alive:
//   (A) the symbol's parent scope is the INNERMOST enclosing statement block;
//   (B) the symbol's parent scope is the block that IS the current control body.
// A PLAIN begin/end nested inside a control body separates them, and so does a
// declaration in the control body read from a nested plain block.
// It also settles the NAMED-block boundary in both nesting directions.
package pb3;
  function automatic void sink(string s); $display(s); endfunction

  class shp;
    static function int f(int obj);
      f = obj;
      // D1: control body -> nested PLAIN begin.  A local declared in the PLAIN
      //     inner block is innermost (A says bind) but the inner block is not a
      //     control body (B says bare).
      if (obj == 0) begin
        string ctl1;
        ctl1 = "c";
        sink(ctl1);            // control: control-body local, own block
        begin
          string pln1;
          pln1 = "p";
          sink(pln1);          // A: BIND   B: bare
          sink(ctl1);          // outer control-body local from a plain inner
        end
      end
      // D2: NAMED outer, UNNAMED inner
      if (obj == 1) begin : onm
        string onmv;
        onmv = "o";
        sink(onmv);            // named block's own local (b2 says bare)
        if (obj == 1) begin
          string inuv;
          inuv = "i";
          sink(inuv);          // UNNAMED inner under a NAMED outer
          sink(onmv);
        end
      end
      // D3: UNNAMED outer, NAMED inner
      if (obj == 2) begin
        string ounv;
        ounv = "o";
        sink(ounv);
        if (obj == 2) begin : inm
          string inmv;
          inmv = "i";
          sink(inmv);          // NAMED inner under an UNNAMED outer
          sink(ounv);
        end
      end
      // D4: the block local read in a nested `if` CONDITION (conditions clear
      //     classMethodNoBind but NOT ctrlBodyNoBind28 -- see the code comment)
      if (obj == 3) begin
        string cndv;
        cndv = "c";
        if (cndv == "c") sink(cndv);
      end
      // D5: a for-loop body's local read inside a nested if inside the loop
      for (int k = 0; k < 2; k++) begin
        string lpv;
        lpv = "l";
        sink(lpv);
        if (k == 0) begin
          sink(lpv);           // loop-body local read one level deeper
        end
      end
      // D6: DEEP nesting, three unnamed control bodies, decl at each level
      if (obj == 4) begin
        string l1;
        l1 = "1";
        sink(l1);
        if (obj == 4) begin
          string l2;
          l2 = "2";
          sink(l2);
          if (obj == 4) begin
            string l3;
            l3 = "3";
            sink(l3);
            sink(l2);
            sink(l1);
          end
        end
      end
      // D7: the SAME reference shape but nested inside an EXPRESSION argument
      //     (concat) -- ClassArgBind12 zeroes on a concat
      if (obj == 5) begin
        string cx;
        cx = "x";
        sink({cx, "y"});
        sink({cx});
      end
    endfunction
  endclass
endpackage

module b3_bound;
  int q;
  initial q = 0;
  pb3::shp sh;
  initial sh = null;
endmodule
