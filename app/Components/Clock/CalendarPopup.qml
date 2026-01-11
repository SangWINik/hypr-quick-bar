import QtQuick
import "../Structure"

ModulePopup {
    id: calendarPopup
    property var stylePath: ["bar", "popup", "calendar"]
    
    popupHeight: contentColumn.implicitHeight + 40
    popupWidth: 280
    
    property date currentDate: new Date()
    property int displayMonth: currentDate.getMonth()
    property int displayYear: currentDate.getFullYear()
    
    onVisibleChanged: {
        if (visible) {
            currentDate = new Date()
            displayMonth = currentDate.getMonth()
            displayYear = currentDate.getFullYear()
        }
    }
    
    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }
    
    function getFirstDayOfMonth(year, month) {
        // Returns 0 for Sunday, 1 for Monday, etc.
        return new Date(year, month, 1).getDay()
    }
    
    function isToday(day) {
        return day === currentDate.getDate() && 
               displayMonth === currentDate.getMonth() && 
               displayYear === currentDate.getFullYear()
    }
    
    function previousMonth() {
        if (displayMonth === 0) {
            displayMonth = 11
            displayYear--
        } else {
            displayMonth--
        }
    }
    
    function nextMonth() {
        if (displayMonth === 11) {
            displayMonth = 0
            displayYear++
        } else {
            displayMonth++
        }
    }
    
    function getMonthName(month) {
        const months = ["January", "February", "March", "April", "May", "June",
                       "July", "August", "September", "October", "November", "December"]
        return months[month]
    }
    
    Column {
        id: contentColumn
        anchors.centerIn: parent
        width: parent.width - 20
        spacing: 12
        
        // Header with month/year and navigation
        Row {
            width: parent.width
            height: 30
            
            // Previous month button
            MouseArea {
                width: 30
                height: 30
                hoverEnabled: true
                
                onClicked: calendarPopup.previousMonth()
                
                Rectangle {
                    anchors.fill: parent
                    color: parent.containsMouse ? config.getStyle(stylePath, "hoverColor", "#4dcdd6f4") : "transparent"
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰁍"
                        color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 18
                    }
                }
            }
            
            // Month and year display
            Item {
                width: parent.width - 60
                height: 30
                
                Text {
                    anchors.centerIn: parent
                    text: calendarPopup.getMonthName(calendarPopup.displayMonth) + " " + calendarPopup.displayYear
                    color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                    font.pixelSize: 16
                    font.bold: true
                }
            }
            
            // Next month button
            MouseArea {
                width: 30
                height: 30
                hoverEnabled: true
                
                onClicked: calendarPopup.nextMonth()
                
                Rectangle {
                    anchors.fill: parent
                    color: parent.containsMouse ? config.getStyle(stylePath, "hoverColor", "#4dcdd6f4") : "transparent"
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰁔"
                        color: config.getStyle(stylePath, "textColor", "#cdd6f4")
                        font.family: "NotoSansMono Nerd Font"
                        font.pixelSize: 18
                    }
                }
            }
        }
        
        // Days of week header
        Grid {
            columns: 7
            columnSpacing: 2
            rowSpacing: 2
            width: parent.width
            
            Repeater {
                model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
                
                Rectangle {
                    width: (contentColumn.width - 12) / 7
                    height: 25
                    color: "transparent"
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: config.getStyle(stylePath, "dimColor", "#99cdd6f4")
                        font.pixelSize: 11
                        font.bold: true
                    }
                }
            }
        }
        
        // Calendar grid
        Grid {
            columns: 7
            columnSpacing: 2
            rowSpacing: 2
            width: parent.width
            
            Repeater {
                model: 42 // 6 rows x 7 days
                
                Rectangle {
                    width: (contentColumn.width - 12) / 7
                    height: 32
                    
                    property int firstDay: calendarPopup.getFirstDayOfMonth(calendarPopup.displayYear, calendarPopup.displayMonth)
                    property int daysInMonth: calendarPopup.getDaysInMonth(calendarPopup.displayYear, calendarPopup.displayMonth)
                    property int dayNumber: index - firstDay + 1
                    property bool isValidDay: dayNumber > 0 && dayNumber <= daysInMonth
                    property bool isCurrentDay: isValidDay && calendarPopup.isToday(dayNumber)
                    
                    color: {
                        if (isCurrentDay) {
                            return config.getStyle(stylePath, "accentColor", "#89b4fa")
                        } else if (isValidDay) {
                            return "transparent"
                        } else {
                            return "transparent"
                        }
                    }
                    
                    radius: 6
                    
                    Text {
                        anchors.centerIn: parent
                        text: parent.isValidDay ? parent.dayNumber : ""
                        color: parent.isCurrentDay ? config.getStyle(stylePath, "backgroundColor", "#1e1e2e") : config.getStyle(stylePath, "textColor", "#cdd6f4")
                        font.pixelSize: 13
                        font.bold: parent.isCurrentDay
                    }
                }
            }
        }
    }
}
