package ;

import haxe.io.Bytes;

class LR35902 {
	// Memory
	public var ram: Bytes;

	// Registers
	public var af(default,set): UInt;
	public var bc(default,set): UInt;
	public var de(default,set): UInt;
	public var hl(default,set): UInt;

	public var pc(default,set): UInt;
	public var sp(default,set): UInt;

	// Virtual flags
	public var ime(default,null) = false;
	public var halt(default,null) = false;

	public var a(get,set): UInt;
	public var b(get,set): UInt;
	public var c(get,set): UInt;
	public var d(get,set): UInt;
	public var e(get,set): UInt;
	public var f(get,set): UInt;
	public var h(get,set): UInt;
	public var l(get,set): UInt;

	public var fz(get,set): Bool;
	public var fn(get,set): Bool;
	public var fh(get,set): Bool;
	public var fc(get,set): Bool;
	
	inline function uint8( v: UInt ): UInt return v & 0xff;
	inline function uint16( v: UInt ): UInt return v & 0xffff;

	inline function set_af( v: UInt ) { var v_ = uint16( v ); af = v_; return v_; }
	inline function set_bc( v: UInt ) { var v_ = uint16( v ); bc = v_; return v_; }
	inline function set_de( v: UInt ) { var v_ = uint16( v ); de = v_; return v_; }
	inline function set_hl( v: UInt ) { var v_ = uint16( v ); hl = v_; return v_; }
	inline function set_pc( v: UInt ) { var v_ = uint16( v ); pc = v_; return v_; }
	inline function set_sp( v: UInt ) { var v_ = uint16( v ); sp = v_; return v_; }

	inline function getLo( hl: UInt ) return 0x00ff & hl;
	inline function getHi( hl: UInt ) return 0xff00 & hl;
	inline function setLo( hl: UInt, v: UInt ) return getHi(hl) + (uint8(v) << 8);
	inline function setHi( hl: UInt, v: UInt ) return getLo(hl) + (uint8(v) << 0);

	public inline function set_a( v: UInt ) { var v_ = uint8(v); af = setHi(af,v_); return v_; }
	public inline function set_b( v: UInt ) { var v_ = uint8(v); bc = setHi(bc,v_); return v_; }
	public inline function set_c( v: UInt ) { var v_ = uint8(v); bc = setLo(bc,v_); return v_; }
	public inline function set_d( v: UInt ) { var v_ = uint8(v); de = setHi(de,v_); return v_; }
	public inline function set_e( v: UInt ) { var v_ = uint8(v); de = setLo(de,v_); return v_; }
	public inline function set_f( v: UInt ) { var v_ = uint8(v); af = setLo(af,v_); return v_; }
	public inline function set_h( v: UInt ) { var v_ = uint8(v); bc = setHi(hl,v_); return v_; }
	public inline function set_l( v: UInt ) { var v_ = uint8(v); bc = setLo(hl,v_); return v_; }

	public inline function get_a() return getHi(af);
	public inline function get_b() return getHi(bc);
	public inline function get_c() return getLo(bc);
	public inline function get_d() return getHi(de);
	public inline function get_e() return getLo(de);
	public inline function get_f() return getLo(af);
	public inline function get_h() return getHi(hl);
	public inline function get_l() return getLo(hl);

	public inline function get_fz() return f & 0x80 == 1;
	public inline function get_fn() return f & 0x40 == 1;
	public inline function get_fh() return f & 0x20 == 1;
	public inline function get_fc() return f & 0x10 == 1;
	
	public inline function set_fz( v: Bool ) { af = v ? af | 0x80 : af & ~0x80; return v; } 
	public inline function set_fn( v: Bool ) { af = v ? af | 0x40 : af & ~0x40; return v; } 
	public inline function set_fh( v: Bool ) { af = v ? af | 0x20 : af & ~0x20; return v; } 
	public inline function set_fc( v: Bool ) { af = v ? af | 0x10 : af & ~0x10; return v; } 

	public static inline var MEMSIZE = 0xffff;

	public function new( ) {
		pc = 0;
		sp = 0;
		ram = Bytes.alloc( MEMSIZE );
		restart();
	}

	function restartMemory() {
		ram.fill( 0, MEMSIZE, 0 );
	}

	public function restart() {
		restartMemory();
	}

	inline function utos8( v: UInt ): Int {
		return v - 0x80;
	}

	// 16-bit arithmetic
	inline function wordInc( r: UInt ) {
		pc++;
		cycles(8);
		return uint16(r+1);
	}

	inline function wordDec( r: UInt ) {
		pc++;
		cycles(8);
		return uint16(r-1);
	}

	inline function wordAdd( r: UInt ) {
		hl += r;
		fc = hl > 0xffff;
		if ( fc ) {
			hl = uint8( hl );
		}	
		fn = false;
		pc++;
		cycles(8);
	}

	static var DEFAULT_BIOS_CODES = [
	  0x31, 0xFE, 0xFF, 0xAF, 0x21, 0xFF, 0x9F, 0x32, 0xCB, 0x7C, 0x20, 0xFB, 0x21, 
		0x26, 0xFF, 0x0E, 0x11, 0x3E, 0x80, 0x32, 0xE2, 0x0C, 0x3E, 0xF3, 0xE2, 0x32, 
		0x3E, 0x77, 0x77, 0x3E, 0xFC, 0xE0, 0x47, 0x11, 0x04, 0x01, 0x21, 0x10, 0x80, 
		0x1A, 0xCD, 0x95, 0x00, 0xCD, 0x96, 0x00, 0x13, 0x7B, 0xFE, 0x34, 0x20, 0xF3, 
		0x11, 0xD8, 0x00, 0x06, 0x08, 0x1A, 0x13, 0x22, 0x23, 0x05, 0x20, 0xF9, 0x3E, 
		0x19, 0xEA, 0x10, 0x99, 0x21, 0x2F, 0x99, 0x0E, 0x0C, 0x3D, 0x28, 0x08, 0x32, 
		0x0D, 0x20, 0xF9, 0x2E, 0x0F, 0x18, 0xF3, 0x67, 0x3E, 0x64, 0x57, 0xE0, 0x42, 
		0x3E, 0x91, 0xE0, 0x40, 0x04, 0x1E, 0x02, 0x0E, 0x0C, 0xF0, 0x44, 0xFE, 0x90, 
		0x20, 0xFA, 0x0D, 0x20, 0xF7, 0x1D, 0x20, 0xF2, 0x0E, 0x13, 0x24, 0x7C, 0x1E, 
		0x83, 0xFE, 0x62, 0x28, 0x06, 0x1E, 0xC1, 0xFE, 0x64, 0x20, 0x06, 0x7B, 0xE2, 
		0x0C, 0x3E, 0x87, 0xE2, 0xF0, 0x42, 0x90, 0xE0, 0x42, 0x15, 0x20, 0xD2, 0x05, 
		0x20, 0x4F, 0x16, 0x20, 0x18, 0xCB, 0x4F, 0x06, 0x04, 0xC5, 0xCB, 0x11, 0x17, 
		0xC1, 0xCB, 0x11, 0x17, 0x05, 0x20, 0xF5, 0x22, 0x23, 0x22, 0x23, 0xC9, 0xCE, 
		0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 
		0x00, 0x0D, 0x00, 0x08, 0x11, 0x1F, 0x88, 0x89, 0x00, 0x0E, 0xDC, 0xCC, 0x6E, 
		0xE6, 0xDD, 0xDD, 0xD9, 0x99, 0xBB, 0xBB, 0x67, 0x63, 0x6E, 0x0E, 0xEC, 0xCC,
		0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E, 0x3C, 0x42, 0xB9, 0xA5, 0xB9,
		0xA5, 0x42, 0x3C, 0x21, 0x04, 0x01, 0x11, 0xA8, 0x00, 0x1A, 0x13, 0xBE, 0x20,
		0xFE, 0x23, 0x7D, 0xFE, 0x34, 0x20, 0xF5, 0x06, 0x19, 0x78, 0x86, 0x23, 0x05, 
		0x20, 0xFB, 0x86, 0x20, 0xFE, 0x3E, 0x01, 0xE0, 0x50];

	static var DEFAULT_BIOS = Bytes.ofString( [ for ( v in DEFAULT_BIOS_CODES ) String.fromCharCode( v )].join(""));

	// RAM functions
	inline function readByte( addr ) {
		return ram.get( addr );
	}

	inline function readWord( addr ) {
		return ram.getUInt16( addr );
	}
	
	inline function writeByte( addr, v ) {
		ram.set( addr, v );
	}

	inline function writeWord( addr, v ) {
		ram.setUInt16( addr, v );
	}

	// Control flow
	inline function jmpSign( v: Bool ) {
		if ( v ) {
			var d8: UInt = readByte(pc+1);
			var dpc = utos8( d8 );
			pc += dpc + 2;
			cycles(12);
		} else {
			pc += 2;
			cycles(8);
		}
	}

	inline function jmp( v: Bool ) {
		if ( v ) {
			pc = readWord( pc+1 );
			cycles(16);
		} else {
			pc += 3;
			cycles(12);
		}
	}
		
	inline function call( v: Bool ) {
		if ( v ) {
			var a16 = readWord( pc+1 );
			sp -= 2;
			writeWord( sp, pc+3 );
			pc = a16;
			cycles(24);
		} else {
			pc += 3;
			cycles(12);
		}
	}

	inline function ret( v: Bool ) {
		if ( v ) {
			pc = readWord( sp );
			sp += 2;
			cycles(20);
		} else {
			pc += 1;
			cycles(8);
		}
	}

	inline function resetPC( addr: UInt ) {
		sp -= 2;
		writeWord( sp, pc+1 );
		pc = addr;
		cycles(16);
	}

	// Stack operations
	inline function stackPush( v: UInt ) {
		sp -= 2 ;
		writeWord( sp, v );
		pc += 1;
		cycles(16);
	}

	inline function stackPop( v: UInt ) {
		var v = readWord( sp );
		sp += 2;
		pc += 1;
		cycles(12);
		return v;
	}

	// Arithmetic operations
	inline function byteAdd( v: UInt ) {
		var hF = (( a & 0xf ) + ( v & 0xf )) > 0xf;
		fc = (a + v) > 0xff;
		a += v;
		fn = false;
		fz = a == 0;
		pc++;
		cycles(4);
	}	

	inline function cycles( v: Int ) {}

	public function run() {
		while ( !halt ) {
			switch ( ram.get( pc )) {
				/*case 0x00: cycles(4); 1; 
				case 0x10: halt = true; cycles(4); 2;
				case 0x76: if ( ime ) halt = true; cycles(4); 1;
				case 0xf3: ime = false; cycles(4); 1;
				case 0xfb: ime = true; cycles(4); 1;
*/
				case 0x18: jmpSign( true );
				case 0x20: jmpSign( !fz );
				case 0x30: jmpSign( !fc );
				case 0x28: jmpSign( fz );
				case 0x38: jmpSign( fc );

				case 0xc3: jmp( true );
				case 0xc2: jmp( !fz );
				case 0xd2: jmp( !fc );
				case 0xca: jmp( fz );
				case 0xda: jmp( fc );

				case 0xcd: call( true );
				case 0xc4: call( !fz );
				case 0xd4: call( !fc );
				case 0xcc: call( fz );
				case 0xdc: call( fc );

				case 0xc9: cycles(16); ret( true );
				case 0xd9: ime = true; cycles(16); ret( true );
				case 0xc0: ret( !fz );
				case 0xd0: ret( !fc );
				case 0xc8: ret( fz );
				case 0xd8: ret( fc );

				case 0xc7: resetPC( 0x00 );
				case 0xd7: resetPC( 0x10 );
				case 0xe7: resetPC( 0x20 );
				case 0xf7: resetPC( 0x30 );
				case 0xcf: resetPC( 0x08 );
				case 0xdf: resetPC( 0x18 );
				case 0xef: resetPC( 0x28 );
				case 0xff: resetPC( 0x38 );

				case 0xe9: pc = hl; cycles(4);

				case 0x03: var v = wordInc( bc ); bc = v;
				case 0x13: var v = wordInc( de ); de = v;
				case 0x23: var v = wordInc( hl ); hl = v;
				case 0x33: sp++; pc++; cycles(8);

				case 0x0b: var v = wordDec( bc ); bc = v;
				case 0x1b: var v = wordDec( de ); de = v;
				case 0x2b: var v = wordDec( hl ); hl = v;
				case 0x3b: sp--; pc--; cycles(8);

				case 0x09: wordAdd( bc );
				case 0x19: wordAdd( de );
				case 0x29: wordAdd( hl );
				case 0x39: wordAdd( sp );

				case 0xe8: 
					var d8 = readByte( pc+1 );
					var s8 = utos8( d8 );
					var tsp = sp + s8;

					if ( s8 >= 0 ) {
						fc = ( getLo(sp) + s8 ) > 0xff;
						fh = ((sp & 0xf)  + (s8 & 0xf)) > 0xf;
					} else {
						fc = getLo(tsp) <= getLo(sp); 
						fh = (tsp & 0xf) <= (sp & 0xf);
					}

					sp = uint16( tsp );
					fz = false;
					fn = false;
					pc += 2;
					cycles(16);

		/*		case 0x01: dc = program.getUInt16( pc+1 ); cycles(16); 3;
				case 0x02: bc = a; cycles(8); 1;
				case 0x03: bc += 1; cycles(8); 1;
				case 0x04: b += 1; fz = b == 0; fn = false; fh = fz; cycles(4); 1;
				case 0x05: b -= 1; fz = b == 0; fn = true; fh = fz; cycles(4); 1;
				case 0x06: b = program.get( pc+1 ); cycles(8); 2;
				case 0x07:*/ 
			}		
		}
	}	
}
