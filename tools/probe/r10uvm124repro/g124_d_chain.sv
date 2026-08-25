// r10uvm124 arm D — CHAINED receivers.  The subscript is carried by
// component 0, by component 1, by both, and by neither, at chain lengths two,
// three and four, so the "first two names" rule and the subscript-as-argument
// rule are each seen alone and together.
package Chain124;
  class Tip;
    int  Ends[$];
    function void Nudge(int V); endfunction
  endclass
  class Mid;
    Tip  Fan[5];
    Tip  Solo;
    int  Direct[$];
  endclass
  class Root;
    Mid   Limb[$];
    Mid   Alias[string];
    Mid   Only;
    task automatic Walk(int Px, string Qx);
      Limb[Px].Solo.Ends.push_back(301);        // idx on 0 only, len 3
      Limb[Px].Fan[Px].Ends.push_back(302);     // idx on 0 and 1, len 3
      Only.Fan[Px].Ends.push_back(303);         // idx on 1 only, len 3
      Only.Solo.Ends.push_back(304);            // no idx, len 3
      Limb[Px].Direct.push_back(305);           // idx on 0, len 2
      Alias[Qx].Fan[2].Ends.push_back(306);     // idx on 0 and 1, len 3
      Limb[Px].Solo.Nudge(307);                 // user method at the tail
      Only.Fan[1].Nudge(308);                   // idx on 1, user method
    endtask
  endclass
endpackage
