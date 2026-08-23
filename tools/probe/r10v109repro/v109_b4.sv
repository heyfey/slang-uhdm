// r10v109repro/v109_b4.sv - ADVERSARIAL: the `= new` lvalue in every CONTROL
// context, plus owner multiplicity (two tops, one child, an import-only module
// and an import-nothing module) and TWO instances of the same module.
// MEASUREMENT ONLY.
package pkb4;

  class Bit4;
    int v;
    function new(int a = 0); v = a; endfunction
  endclass

  class Rig4;
    Bit4 loopNewIota;      // `= new` inside a for loop body
    Bit4 forkNewZeta;      // `= new` inside a fork...join
    Bit4 caseNewEta;       // `= new` inside a case item
    Bit4 feachNewTheta[3]; // `= new` inside a foreach body, indexed by the ITERATOR
    Bit4 whileNewUps;      // `= new` inside a while body
    Bit4 ifNewOmi;         // `= new` inside an if/else
    int  ctlNu4;           // plain LHS control, must KEEP its wire
    int  readNu5;          // plain read control, must KEEP its wire
    extern task b4run();
  endclass

  task Rig4::b4run();
    int j4;
    for (int i4 = 0; i4 < 2; i4++)
      loopNewIota = new(i4);            // F1 for-body
    fork
      forkNewZeta = new(1);             // F2 fork
    join
    case (ctlNu4)
      0: caseNewEta = new(2);           // F3 case item
      default: ;
    endcase
    foreach (feachNewTheta[k4])
      feachNewTheta[k4] = new(k4);      // F4 foreach body, ITERATOR index
    while (j4 < 1) begin
      whileNewUps = new(3);             // F5 while body
      j4 = j4 + 1;
    end
    if (readNu5 == 0) ifNewOmi = new(4); // F6 if-body (readNu5 is a plain read)
    else              ifNewOmi = new(5);
    ctlNu4 = 9;                          // F7 plain LHS control
  endtask

endpackage

module kidb4;
  import pkb4::*;
  Rig4 rk;
  initial begin rk = new(); rk.b4run(); end
endmodule

module topb4a;
  import pkb4::*;
  kidb4 c1();
  kidb4 c2();          // TWO instances of the same child
  Rig4 ra;
  initial begin ra = new(); ra.b4run(); end
endmodule

module topb4b;
  import pkb4::*;      // imports but NEVER calls
endmodule

module topb4c;         // imports NOTHING
  wire dummy4;
endmodule
