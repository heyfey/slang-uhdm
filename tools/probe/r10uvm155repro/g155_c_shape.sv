// r10uvm155 grid, arm C — THE SHAPE axis: declarator COUNT, INITIALISER,
// DECLARATION ORDER, ARRAY spellings, PACKED dimensions on the use, a NESTED
// block, and the SHADOW gate measured from three directions.  MEASUREMENT ONLY.
package Loom155;
  typedef bit [2:0] loomSpool;            // a package typedef, for the shadow cells

  class Shuttle155;
    typedef bit [3:0] shuttleReed;        // a class typedef, for the shadow cells

    function void weave();
      typedef bit [4:0] weftKind;
      // 1, 2 and 3 declarators off ONE declaration
      weftKind warpOne;
      weftKind warpTwoA, warpTwoB;
      weftKind warpThreeA, warpThreeB, warpThreeC;
      // WITH an initialiser, alone and mixed
      weftKind warpInit = 5'd3;
      weftKind warpMixA = 5'd1, warpMixB;
      // ARRAY spellings off the same local typedef
      weftKind warpFixed [4];
      weftKind warpQueue [$];
      weftKind warpDyn   [];
      weftKind warpAssoc [string];
      // PACKED dimensions written at the USE
      weftKind [1:0] warpPacked;
      // a NESTED begin using the OUTER block's typedef, and its own
      begin
        weftKind warpFromOuter;
        typedef bit [5:0] pickKind;
        pickKind pickOwn;
        warpFromOuter = 0; pickOwn = 0;
      end
      // SHADOW cells: a local typedef whose name is ALSO a package typedef,
      // and one whose name is ALSO this class's typedef.
      begin
        typedef bit [6:0] loomSpool;      // shadows the PACKAGE name
        typedef bit [7:0] shuttleReed;    // shadows the CLASS name
        typedef bit [8:0] heddleOnly;     // shadows NOTHING
        loomSpool   shadowPkgName;
        shuttleReed shadowClsName;
        heddleOnly  shadowNone;
        shadowPkgName = 0; shadowClsName = 0; shadowNone = 0;
      end
      warpOne = 0; warpTwoA = 0; warpTwoB = 0;
      warpThreeA = 0; warpThreeB = 0; warpThreeC = 0;
      warpMixB = 0; warpFixed[0] = 0; warpQueue.push_back(0);
      warpAssoc["x"] = 0; warpPacked = 0;
    endfunction
  endclass
endpackage
