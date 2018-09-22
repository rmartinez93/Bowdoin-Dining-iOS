//
//  ScheduleUtils.swift
//  Bowdoin Dining
//
//  Created by Ruben Martinez on 9/22/18.
//

// A day of the week.
enum Day: Int {
    case Sunday = 1, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

// A point in time (resolution up to the day, down to minute).
class ScheduleTime {
    let day: Day
    let hour: Int
    let minute: Int
    
    init(day: Day, hour: Int, minute: Int) {
        self.day = day
        self.hour = hour
        self.minute = minute
    }
    
    // This time is before other time.
    func isBefore(_ other: ScheduleTime) -> Bool {
        return !self.isAfter(other)
    }
    
    // This time is after other time.
    func isAfter(_ other: ScheduleTime) -> Bool {
        return self.day.rawValue > other.day.rawValue || // different day
            ((self.day.rawValue == other.day.rawValue) && self.hour > other.hour) || // different hour
            ((self.day.rawValue == other.day.rawValue && self.hour == other.hour) && self.minute >= other.minute) // different minute
    }
}

enum ScheduleEntryError: Error {
    case startTimeBeforeEndTime
}

// A time range.
class ScheduleEntry {
    let startTime: ScheduleTime
    let endTime: ScheduleTime
    
    init(startTime: ScheduleTime, endTime: ScheduleTime) throws {
        // Verify start time is before end time.
        if startTime.isAfter(endTime) {
            throw ScheduleEntryError.startTimeBeforeEndTime
        }
        
        self.startTime = startTime
        self.endTime = endTime
    }
}

// A set of non-overlapping time ranges.
class Schedule {
    let schedule: [ScheduleEntry]
    
    init(_ schedule: [ScheduleEntry]) {
        // Theoretically this should also verify that
        // schedule entries don't overlap, but *shrugs*
        
        self.schedule = schedule
    }
    
    // Checks that the given time doesn't conflict with current schedule entries.
    // e.g. If the schedule is a set of times when the pub is open,
    // this would return true if pub is open at this time, false if closed.
    func hasConflicts(time: ScheduleTime) -> Bool {
        return schedule.contains { (scheduleEntry) -> Bool in
            if (time.isBefore(scheduleEntry.startTime) || time.isAfter(scheduleEntry.endTime)) {
                return false
            }
            
            return true
        }
    }
}
