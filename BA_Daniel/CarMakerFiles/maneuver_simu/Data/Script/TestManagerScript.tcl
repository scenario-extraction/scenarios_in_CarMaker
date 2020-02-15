proc MyEndProc {key name args} {
 global TestNo
 global storageFolder

 switch $key {
  TestSeries {}
  Group {}
  TestRunGroup {}
  TestRun {
      # only evaluate criteria if simulation was successful so far
      if {[TestMgr::GetResult] != "good"}{

       Log "Exporting Image-Series..."
       Movie export window pic.png 0 -suffix frame_%sizeX%x%sizeY% -view front -start 0.5 -framerate 20 -size {700 600}

       return

       }

       PowerOn
       Diag connect
       set Diag geterrors
       set Errors [Diag geterrorcodes]
       Diag disconnect
       if {[llength $Errors] > 0} {
        TestMgr::SetResult bad
        foreach err $Errors { Log $err }

       }
       set ::TS::Test($TestNo,nErrors) [llength $Errors]
       set ::TS::Test($TestNo,ErrCodes) $Errors
       incr TestNo
   } 
   default {Log "MyEndProc unknown key ’$key’"; TestMgr::Stop}
 }
}



proc StartProc {key name args} {
 global TestNo
 global TimeSeriesId

 switch $key {
  TestSeries {
      	Movie start
	set TestNo 0
	Log "Starting Testseries..."
	#Movie window fullscreen on
  }
  TestRun {
	Log "Starting TestNo: $TestNo in TestRun: $name"

	#create direcotry for date [clock format $systemTime -format %d%m%y%H%M%S]

	set TimeSeriesId [clock seconds] 

	SaveMode save
	SetResultFName  D:/Storage/CarMaker/$name-$TestNo-$TimeSeriesId/OutputQuantities


	#set random Namedvalues


	NamedValue set laneChangeDur [myRand 3 10]
	NamedValue set mediumSpeed [myRand 90 130]

	set currentLaneId 0
	set laneChangeDir 0

	NamedValue set manNo1Dur [myRand 10 50]
	NamedValue set manNo1Speed [myRand 80 140] 
	NamedValue set manNo2Dur [myRand 2 10]
	set laneChangeDir [myRandLaneChange $currentLaneId]
	NamedValue set manNo2Lane $laneChangeDir
	incr currentLaneId  $laneChangeDir

	NamedValue set manNo3Dur [myRand 10 50]
	NamedValue set manNo3Speed [myRand 80 140] 
	NamedValue set manNo4Dur [myRand 2 10]
	set laneChangeDir [myRandLaneChange $currentLaneId]
	NamedValue set manNo4Lane $laneChangeDir
	incr currentLaneId  $laneChangeDir


	NamedValue set manNo5Dur [myRand 10 50]
	NamedValue set manNo5Speed [myRand 80 140] 
	NamedValue set manNo6Dur [myRand 2 10]
	set laneChangeDir [myRandLaneChange $currentLaneId]
	NamedValue set manNo6Lane $laneChangeDir
	incr currentLaneId  $laneChangeDir


	NamedValue set manNo7Dur [myRand 10 50]
	NamedValue set manNo7Speed [myRand 80 140] 
	NamedValue set manNo8Dur [myRand 2 10]
	set laneChangeDir [myRandLaneChange $currentLaneId]
	NamedValue set manNo8Lane $laneChangeDir
	incr currentLaneId  $laneChangeDir


	NamedValue set manNo9Dur [myRand 10 50]
	NamedValue set manNo9Speed [myRand 80 140] 
	NamedValue set manNo10Dur [myRand 2 10]
	set laneChangeDir [myRandLaneChange $currentLaneId]
	NamedValue set manNo10Lane $laneChangeDir
	incr currentLaneId  $laneChangeDir

	#set valsFileName "D:/Storage/CarMaker/$name-$TestNo-$TimeSeriesId/startValues.txt"
	#set fileId [open $valsFileName "w"]


	foreach p [NamedValue names] { 
		Log "<$p> is set to <[NamedValue get $p]>"
		#puts $fileId "$p = [NamedValue get $p]" 
	}

	#close $fileId

	Movie attach
	Movie camera select "CameraRoofTop" -window 0 -view 0

  }
 }
}

proc myRand { min max } {
    set maxFactor [expr [expr $max + 1] - $min]
    set value [expr int([expr rand() * 100])]
    set value [expr [expr $value % $maxFactor] + $min]
return $value
}

proc myRandLaneChange {currLane} {

 if { $currLane == 0 } {
    set maxFactor [expr [expr 2] + 1]
    set value [expr int([expr rand() * 100])]
    set value [expr [expr $value % $maxFactor] - 1]
    if { $value <= 0 } {
	 return -1
    } else {
	return 1
    }
 } elseif { $currLane == -1 } {
    return 1
 } else {
    return -1
 }
}

proc ExportProc {key name args} {
 global TestNo
 global TimeSeriesId

 switch $key {
  TestSeries {
     Log "TestSeries Finished"
  }
  TestRun {

	#set valsFileName "D:/Storage/CarMaker/$name-$TestNo-$TimeSeriesId/startValues.txt"
	#set fileId [open $valsFileName "w"]
	

	#puts $fileId "Result = [TestMgr::GetResult]" 

	#close $fileId

        #Log "Exporting Image-Series..."

	set movieTitle "testRunGood"

	if {[TestMgr::GetResult] != "good"}{
		set movieTitle "testRunBad"
       	}




	set thisTestNo $TestNo
	incr TestNo	

#	set exportTime 0
#
#       Movie export window D:/Storage/CarMaker/$name-$thisTestNo-$TimeSeriesId/$imageSeriesName/pic.png 0  -start start -end end -framerate 20 -async
#	while { [Movie export status] } {
#		sleep 5000
#		incr exportTime 5000
#		Log [Movie export status -detailed]		
#	}
#	Log "Exported Image-Series in: $exportTime"

	set exportTime 0

	Movie export window D:/Storage/CarMaker/$name-$thisTestNo-$TimeSeriesId/$movieTitle.mp4 0 -async
	while { [Movie export status] } {
		sleep 5000
		incr exportTime 5000
		Log [Movie export status -detailed]		
	}
	Log "Exported Video in: $exportTime"


	Log "Export finished..."
 

   
 
  }
 }
}

