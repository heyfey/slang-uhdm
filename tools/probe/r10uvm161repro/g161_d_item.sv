// r10uvm161 arm D — THE CASE-ITEM COLUMN and THE EVENT-CONTROL COLUMN.
// Arm B proved the `if` CONDITION and the IMMEDIATE ASSERTION CONDITION give
// golden's SAME answer for eighteen referent kinds.  This arm asks the same
// question of the other two § refVarLocalWindowBinds5 window sites our emitter
// raises the counter at but does NOT clear `classMethodNoBind` at:
//   * the CASE ITEM EXPRESSION  (window site 4)   — this pass opens it
//   * the EVENT CONTROL expression (window site 6) — left to § 108, and this
//     arm is what says so honestly rather than by assumption
// Every cell has its own name and number; the `if` column is the control.
package pkgd161;

  typedef enum int { SORREL161 = 6, ISABEL161 = 8 } coats161_e;

  int pkgvar161 = 12;
  parameter int PKGPAR161 = 14;

  class item161;
    int prop161;
    static int sprop161;
    coats161_e coat161;
    event bellrope161;

    task columns161(int drayage161);
      int wainscot161;
      coats161_e roan161;
      event tabor161;

      // ---------- CONTROL: the `if` CONDITION ----------
      if (wainscot161 == 301) prop161 = 302;
      if (drayage161 == 303) prop161 = 304;
      if (prop161 == 305) wainscot161 = 306;
      if (sprop161 == 307) wainscot161 = 308;
      if (roan161 == SORREL161) wainscot161 = 309;
      if (coat161 == ISABEL161) wainscot161 = 310;
      if (pkgvar161 == 311) wainscot161 = 312;
      if (PKGPAR161 == 313) wainscot161 = 314;

      // ---------- COLUMN: the CASE ITEM EXPRESSION ----------
      case (321)
        wainscot161: prop161 = 322;                 // plain local
        drayage161:  prop161 = 323;                 // formal
        prop161:     wainscot161 = 324;             // class property
        sprop161:    wainscot161 = 325;             // static property
        pkgvar161:   wainscot161 = 326;             // package variable
        PKGPAR161:   wainscot161 = 327;             // package parameter
        default:     wainscot161 = 328;
      endcase
      case (roan161)
        SORREL161:   prop161 = 329;                 // enum const item
        default:     prop161 = 330;
      endcase
      case (331) inside                             // `case … inside`: NOT a window
        wainscot161: prop161 = 332;
        default:     prop161 = 333;
      endcase
      casex (334)
        wainscot161: prop161 = 335;                 // casex item
        default:     prop161 = 336;
      endcase

      // ---------- COLUMN: the EVENT CONTROL expression ----------
      @(tabor161) prop161 = 341;                    // event LOCAL
      @(bellrope161) prop161 = 342;                 // event PROPERTY
      @(posedge wainscot161) prop161 = 343;         // local in an edge event
    endtask
  endclass

endpackage
