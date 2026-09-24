// v158 arm D — BLOCK SHAPES around the rejected statement.
package Spk;
  class token5;
    static function token5 born(string s); born = new(); endfunction
  endclass

  class Shape5 #(type SS = int);
    // one local + ONE statement
    function void one5();
      if (1) begin
        SS p5;
        p5 = SS::born("p5");
      end
    endfunction
    // one local + TWO statements (bad one FIRST)
    function void twoFirst5();
      if (1) begin
        SS q5;
        q5 = SS::born("q5");
        q5 = q5;
      end
    endfunction
    // one local + TWO statements (bad one LAST)
    function void twoLast5();
      int r5keep;
      if (1) begin
        SS r5;
        r5keep = 1;
        r5 = SS::born("r5");
      end
    endfunction
    // NO local at all (must stay: no handle)
    function void noLocal5();
      if (1) begin
        SS::born("s5");
      end
    endfunction
    // ELSE arm
    function void elseArm5(int k5);
      if (k5 == 0) begin
        int t5;
        t5 = 1;
      end
      else begin
        SS u5;
        u5 = SS::born("u5");
      end
    endfunction
    // CASE item
    function void caseArm5(int k5);
      case (k5)
        1: begin
             SS v5;
             v5 = SS::born("v5");
           end
        default: begin
             int w5;
             w5 = 3;
           end
      endcase
    endfunction
    // FORK arm
    task forkArm5();
      fork
        begin
          SS x5;
          x5 = SS::born("x5");
        end
        begin
          int y5;
          y5 = 4;
        end
      join
    endtask
    // WHILE body, FOR body, DO-WHILE body
    task loops5();
      int n5;
      n5 = 0;
      while (n5 < 2) begin
        SS z5;
        z5 = SS::born("z5");
        n5 = n5 + 1;
      end
      for (int i5 = 0; i5 < 2; i5++) begin
        SS a5;
        a5 = SS::born("a5");
      end
      do begin
        SS b5;
        b5 = SS::born("b5");
        n5 = n5 - 1;
      end while (n5 > 0);
    endtask
    // NESTED: rejected inside rejected, and accepted inside rejected
    function void nest5();
      if (1) begin
        SS c5;
        begin
          SS d5;
          d5 = SS::born("d5");
        end
        begin
          int e5;
          e5 = 9;
        end
        c5 = SS::born("c5");
      end
    endfunction
  endclass
endpackage

module wtop_d;
  initial begin
    int guard5;
    guard5 = 0;
  end
endmodule
