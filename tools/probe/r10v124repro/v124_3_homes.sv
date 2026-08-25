// r10v124 arm 3 — HOMES: class method (in-body + out-of-body), free package
// function, free package task, module task, interface task, module initial,
// module always, and a GENERATE-SCOPE block.
interface Conduit;
  typedef byte Spool[$];
  Spool Bins[string];
  task shove(string kx);
    Bins[kx].push_back(8'h21);
  endtask
endinterface

package Depot;
  typedef byte Spool[$];

  class Crate;
    Spool Bins[string];
    Spool Racks[3];
    function void inbody(string kx);
      Bins[kx].push_back(8'h31);
    endfunction
    extern function void outbody_fn(string kx);
    extern task outbody_tk(string kx);
  endclass

  function void Crate::outbody_fn(string kx);
    Bins[kx].push_back(8'h32);
    Racks[1].push_back(8'h33);
  endfunction

  task Crate::outbody_tk(string kx);
    Bins[kx].push_back(8'h34);
  endtask

  Spool Loose[string];
  Spool Fixed[2];

  function void freefn(string kx);
    Loose[kx].push_back(8'h41);
    Fixed[0].push_back(8'h42);
  endfunction

  task freetk(string kx);
    Loose[kx].push_back(8'h43);
  endtask
endpackage

module Yard #(parameter int WIDE = 1);
  import Depot::*;
  typedef byte Spool2[$];
  Spool2 Shelf[string];
  Spool2 Tier[2];

  task modtask(string kx);
    Shelf[kx].push_back(8'h51);
    Tier[1].push_back(8'h52);
  endtask

  initial begin
    Shelf["init"].push_back(8'h53);
    Tier[0].push_back(8'h54);
    modtask("mt");
  end

  always @(*) begin
    Shelf["alw"].push_back(8'h55);
  end

  generate
    if (WIDE == 1) begin : Loft
      Spool2 Perch[string];
      Spool2 Ledge[2];
      initial begin
        Perch["gen"].push_back(8'h61);
        Ledge[1].push_back(8'h62);
      end
    end
  endgenerate

  Conduit cdt();
  initial cdt.shove("ifc");
endmodule
