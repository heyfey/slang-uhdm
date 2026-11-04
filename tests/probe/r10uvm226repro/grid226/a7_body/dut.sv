// arm a7: WHAT THE BODY HOLDS.  `UhdmWriter::writeInterface` (UhdmWriter.cpp
// :1626-1794) contains NO `lateBinding` call at all (r10uvm218's decode), so an
// UNINSTANTIATED interface's process body keeps only whatever Surelog's eager
// compile-time binding gave it.  This arm reads every referent kind an interface
// process can name, in both an uninstantiated and an instantiated interface, so
// the two columns can be diffed cell for cell.
package p226b;
   int pkg226_v = 7;
   localparam int PK226 = 3;
endpackage

interface if226_b();
   import p226b::*;
   localparam int LP226 = 5;
   parameter int PP226 = 6;
   logic       clk226;
   logic       mv226;              // member variable
   wire        mw226;              // member net
   int         arr226 [3];
   int         q226;

   function automatic int f226(int a226);
      return a226 + 1;
   endfunction

   task automatic t226(int a226);
      q226 = a226;
   endtask

   initial begin : b226_named
      automatic int loc226 = 1;    // subroutine-style local in a NAMED block
      mv226 = 1'b0;                // member variable, assignment LHS
      q226  = LP226;               // localparam, assignment RHS
      q226  = PP226;               // parameter
      q226  = pkg226_v;            // wildcard-imported package variable
      q226  = p226b::PK226;        // package-scoped localparam
      q226  = f226(loc226);        // own function call, arg = block local
      t226(loc226);                // own task call
      if (mv226 == 1'b1) q226 = 1; // an if CONDITION (a binding window)
      foreach (arr226[i226])       // a foreach header
         q226 = arr226[i226];
      $display("a7 %0d", q226);    // a SYSTEM call argument
   end

   always @(posedge clk226) begin  // unnamed block
      int loc2226;                 // local in an UNNAMED block
      loc2226 = q226;
      case (loc2226)
         0: q226 = 1;
         default: q226 = 2;
      endcase
   end
endinterface

// The INSTANTIATED twin, byte-identical body.
interface if226_bi();
   import p226b::*;
   localparam int LP226 = 5;
   parameter int PP226 = 6;
   logic       clk226;
   logic       mv226;
   wire        mw226;
   int         arr226 [3];
   int         q226;

   function automatic int f226(int a226);
      return a226 + 1;
   endfunction

   task automatic t226(int a226);
      q226 = a226;
   endtask

   initial begin : b226_named
      automatic int loc226 = 1;
      mv226 = 1'b0;
      q226  = LP226;
      q226  = PP226;
      q226  = pkg226_v;
      q226  = p226b::PK226;
      q226  = f226(loc226);
      t226(loc226);
      if (mv226 == 1'b1) q226 = 1;
      foreach (arr226[i226])
         q226 = arr226[i226];
      $display("a7 %0d", q226);
   end

   always @(posedge clk226) begin
      int loc2226;
      loc2226 = q226;
      case (loc2226)
         0: q226 = 1;
         default: q226 = 2;
      endcase
   end
endinterface

module top226_b;
   if226_bi u_bi226();
endmodule
