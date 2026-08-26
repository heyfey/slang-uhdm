// r10uvm155 grid, arm E — THE EDGE arm.  A statement-scope typedef whose NAME
// collides with a CLASS or a MODULE (`compileVariable` looks those up
// SEPARATELY from `getDataType`), a `const` / `automatic` / `static` local, a
// FORWARD typedef, and the four DECLARATOR-ARRAY forms in a module task.
// MEASUREMENT ONLY.
package Foundry155;
  class Crucible155;
    typedef bit [2:0] crucibleGrade;
  endclass

  class Bellows155;
    function void blow();
      // the local typedef's NAME is also a CLASS name in the design
      typedef bit [3:0] Crucible155;
      Crucible155 clashClassName;
      // ordinary controls next to it
      typedef bit [4:0] emberGauge;
      const emberGauge  constEmber = 5'd7;
      automatic emberGauge autoEmber = 5'd1;
      static emberGauge staticEmber = 5'd2;
      emberGauge plainEmber;
      clashClassName = 0; plainEmber = 0;
    endfunction
  endclass
endpackage

module Forge155;
  task hammer();
    // the local typedef's NAME is also a MODULE name in the design
    typedef bit [5:0] Anvil155;
    Anvil155 clashModuleName;
    // the four DECLARATOR-ARRAY forms off a statement-scope typedef
    typedef bit [6:0] tongsWidth;
    tongsWidth tongsFixed [3];
    tongsWidth tongsQueue [$];
    tongsWidth tongsDyn   [];
    tongsWidth tongsAssoc [int];
    clashModuleName = 0;
    tongsFixed[0] = 0; tongsQueue.push_back(0); tongsAssoc[0] = 0;
  endtask
  initial hammer();
endmodule

module Anvil155;
  initial begin
    // nothing; this module exists only to give `Anvil155` a design entry
  end
endmodule
