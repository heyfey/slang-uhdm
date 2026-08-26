// v158 arm E — LISTING CONTENT: counts, order, initializers, labels, params.
package Npk;
  class knob1;
    static function knob1 forge(string s); forge = new(); endfunction
    function int val(); return 1; endfunction
  endclass

  class List1 #(type NN = int);
    // ZERO locals (no handle - must stay)
    function void zero1();
      if (1) begin
        NN::forge("zz");
      end
    endfunction
    // ONE local
    function void one1();
      if (1) begin
        NN aa1;
        aa1 = NN::forge("aa1");
      end
    endfunction
    // TWO locals in ONE begin, declared in a deliberate order
    function void two1();
      if (1) begin
        string bb1;
        NN cc1;
        bb1 = "bb1";
        cc1 = NN::forge("cc1");
      end
    endfunction
    // THREE locals, mixed kinds
    function void three1();
      if (1) begin
        NN dd1;
        int ee1;
        knob1 ff1;
        dd1 = NN::forge("dd1");
        ee1 = 0;
        ff1 = null;
      end
    endfunction
    // local WITH AN INITIALIZER
    function void init1();
      if (1) begin
        int gg1 = 12;
        NN hh1;
        hh1 = NN::forge("hh1");
      end
    endfunction
    // local READ BEFORE WRITTEN
    function int read1();
      read1 = 0;
      if (1) begin
        int ii1;
        NN jj1;
        read1 = ii1;
        jj1 = NN::forge("jj1");
      end
    endfunction
    // NAMED rejected block WITH locals  (label + end label)
    function void named1();
      begin : mark1
        NN kk1;
        kk1 = NN::forge("kk1");
      end : mark1
    endfunction
    // NAMED rejected block WITHOUT locals (no handle - must stay)
    function void namedZero1();
      begin : mark2
        NN::forge("mark2");
      end : mark2
    endfunction
    // NAMED FORK with a local
    task namedFork1();
      fork : mark3
        begin
          NN ll1;
          ll1 = NN::forge("ll1");
        end
      join : mark3
    endtask
    // block-scope LOCALPARAM beside the locals
    function void param1();
      if (1) begin
        localparam int PW1 = 5;
        NN mm1;
        mm1 = NN::forge("mm1");
      end
    endfunction
    // ARRAY / QUEUE / ASSOC locals in a rejected block
    function void bags1();
      if (1) begin
        int nn1 [4];
        int oo1 [$];
        int pp1 [string];
        NN qq1;
        qq1 = NN::forge("qq1");
      end
    endfunction
    // TWO SIBLING rejected blocks in one method
    function void twins1();
      if (1) begin
        NN rr1;
        rr1 = NN::forge("rr1");
      end
      if (1) begin
        NN ss1;
        ss1 = NN::forge("ss1");
      end
    endfunction
    // ACCEPTED twin of named1 (label must survive both ways)
    function void namedOk1();
      begin : mark4
        int tt1;
        tt1 = 6;
      end : mark4
    endfunction
  endclass
endpackage

module wtop_e;
  initial begin : hold1
    int uu1;
    uu1 = 1;
  end
endmodule
