// r10uvm57repro/b2_shape.sv -- WHICH BLOCK SHAPES, WHICH DEPTHS.  All cells are
// USER-call arguments inside an IN-BODY class method, so ctrlBodyNoBind28 is the
// only thing in play.  The naming suffix says what the cell is testing.
package pb2;
  function automatic void sink(string s); $display(s); endfunction
  function automatic void sinki(int i); $display(i); endfunction

  class shp;
    static function int f(int obj);
      string mbody;
      mbody = "m";
      f = obj;
      // C0: a plain begin/end that is NOT a control body (depth 0)
      begin
        string d0blk;
        d0blk = "0";
        sink(d0blk);
        sink(mbody);
      end
      // C1: NAMED control-body block
      if (obj == 0) begin : nmd
        string nmdblk;
        nmdblk = "n";
        sink(nmdblk);
      end
      // C2: NESTED unnamed, two deep, each with its own decl; the OUTER local
      //     is also read from the INNER body.
      if (obj == 1) begin
        string outr;
        outr = "o";
        sink(outr);                 // depth 1, own block
        if (obj == 1) begin
          string innr;
          innr = "i";
          sink(innr);               // depth 2, own block
          sink(outr);               // depth 2, OUTER block's local
          sink(mbody);              // depth 2, method-body local (control)
        end
      end
      // C3: TWO SIBLING blocks declaring the SAME name
      if (obj == 2) begin
        string dup;
        dup = "1";
        sink(dup);
      end
      if (obj == 3) begin
        string dup;
        dup = "2";
        sink(dup);
      end
      // C4: for-loop body block + the loop VARIABLE itself
      for (int fi = 0; fi < 2; fi++) begin
        string forblk;
        forblk = "f";
        sink(forblk);
        sinki(fi);                  // the for LOOP VARIABLE
      end
      // C5: while body
      while (obj > 9) begin
        string whlblk;
        whlblk = "w";
        sink(whlblk);
        obj = obj - 1;
      end
      // C6: forever+break is unclean; use repeat
      repeat (2) begin
        string rptblk;
        rptblk = "r";
        sink(rptblk);
      end
      // C7: case item block
      case (obj)
        4: begin
             string csblk;
             csblk = "c";
             sink(csblk);
           end
        default: begin
             string dfblk;
             dfblk = "d";
             sink(dfblk);
           end
      endcase
      // C8: else branch
      if (obj == 5) sinki(obj);
      else begin
        string elsblk;
        elsblk = "e";
        sink(elsblk);
      end
    endfunction

    static task t(int obj);
      // C9: fork/join arm block
      fork
        begin
          string frkblk;
          frkblk = "k";
          sink(frkblk);
        end
      join
      // C10: foreach body
      begin
        int arr[3];
        foreach (arr[i]) begin
          string feblk;
          feblk = "e";
          sink(feblk);
          sinki(arr[i]);
        end
      end
    endtask
  endclass
endpackage

module b2_shape;
  int q;
  initial q = 0;
  pb2::shp sh;
  initial sh = null;
endmodule
