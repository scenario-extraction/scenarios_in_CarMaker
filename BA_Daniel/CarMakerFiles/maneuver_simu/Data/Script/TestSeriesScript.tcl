TestMgr load "TestRunAutobahn.ts"

Log "creating TestRunAutobahnFinal_0.ts" 
 
set varPerTestRun 3
set testRunsTotal 5


#open original files
set fp_curve [open "C:/CM_Projects/maneuver_simu/Data/TestRun/curveAutobahn" r]
set file_data_curve [read $fp_curve]
close $fp_curve

set fp_straight [open "C:/CM_Projects/maneuver_simu/Data/TestRun/straightAutobahn" r]
set file_data_straight [read $fp_straight]
close $fp_straight

#get vehicle list...
set dirnames [glob -directory "C:/IPG/carmaker/win64-8.1/Movie/3D/Vehicles" *.mobj]
set vehicles {}
foreach f $dirnames {
	if { [string first Wheel $f] == -1 && [string first Trailer $f] == -1 && [string first JohnDeere $f] == -1} {
		#Log "Appending: [string replace $f 0 31]"
		lappend vehicles [string replace $f 0 31]
	} else {
		#Log "Excluded: $f" 
	}
}


set testRunCounter 1
while { $testRunCounter < $testRunsTotal } {

	set curveAutFileName "C:/CM_Projects/maneuver_simu/Data/TestRun/curveAutobahn_$testRunCounter"
	set fileId [open $curveAutFileName "w"]

	set newTrafficObjLine "Traffic.0.Movie.Geometry = [lindex $vehicles [expr {int(rand()*[llength $vehicles])}]]"

	#  Process original data file
	set data [split $file_data_curve "\n"]
	foreach line $data {
	     # do some line processing here
		if { [string first Traffic.0.Movie.Geometry $line] > -1} {
			puts $fileId $newTrafficObjLine 
		} else { 
			puts $fileId $line
		}
	}

	close $fileId



	set straightAutFileName "C:/CM_Projects/maneuver_simu/Data/TestRun/straightAutobahn_$testRunCounter"
	set fileId [open $straightAutFileName "w"]

	set newTrafficObjLine2 "Traffic.0.Movie.Geometry = [lindex $vehicles [expr {int(rand()*[llength $vehicles])}]]"

	#  Process original data file
	set data [split $file_data_straight "\n"]
	foreach line $data {
		if { [string first Traffic.0.Movie.Geometry $line] > -1} {
			puts $fileId $newTrafficObjLine2 
		} else { 
			puts $fileId $line
		}
	}

	close $fileId




	TestMgr additem TestRun "curveAutobahn_$testRunCounter"
	set i 0
	while {$i < $varPerTestRun} {
		incr i
		TestMgr additem Variation Variation
	}

	Log "Added TestRun: curveAutobahn_$testRunCounter with Car: $newTrafficObjLine"



	TestMgr additem TestRun "straightAutobahn_$testRunCounter"
	set i 0
	while {$i < $varPerTestRun} {
		incr i
		TestMgr additem Variation Variation
	}

	Log "Added TestRun: straightAutobahn_$testRunCounter with Car: $newTrafficObjLine2"

	incr testRunCounter
}

TestMgr save "TestRunAutobahn_0.ts"
