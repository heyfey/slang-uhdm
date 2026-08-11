interface ifa(input bit clock);
   parameter st = 5ns;
   parameter ht = 3ns;
   wire a, b, c, d;
   clocking cb1@(posedge clock);
      default input #st output #ht;
      output a;
   endclocking
   clocking cb2@(posedge clock);
      default input #1 output #2;
      output b;
   endclocking
   clocking cb3@(posedge clock);
      default input #1step;
      output c;
   endclocking
   clocking cb4@(posedge clock);
      input #3 d;
   endclocking
endinterface

module mtop;
   bit clk = 0;
   wire e;
   default clocking cb5@(posedge clk);
      default input #4 output #5;
      output e;
   endclocking
   ifa i0(clk);
endmodule
