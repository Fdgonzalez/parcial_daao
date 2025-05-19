require 'minitest/autorun'
require_relative '../reporting_system'

class ReportingSystemTest < Minitest::Test
  def setup
    employee = Employee.new("Juan", 1000, 10)
    department = Department.new("Accounting", 100000)
    department.assign_employee(Employee.new("Marcos", 1000, 45))
    department.assign_employee(Employee.new("Luciana", 1000, 45))
    department.assign_employee(Employee.new("Carlitos", 1000, 45))
    project = Project.new("Secret project", "2025-2026", "Green")
    project.assign_employee(Employee.new("Max Power", 1000, 45))
    project.assign_employee(Employee.new("John Doe", 1000, 45))    
    @business_units = [employee , department, project]
  end

  def test_plain_text_report
    report = PlainTextReportVisitor.new
    @business_units.each do |business_unit|
      business_unit.accept(report)
    end
    expected = <<-EOF
Employee Juan
Worked hours: 10
Salary: $1000
Department Accounting
Budget: $100000
Assigned hours: 135
Total cost: $3000
Project Secret project
Status: Green
Assigned hours: 90
Total cost: $2000
    EOF
    assert_equal expected ,report.get_report()
  end

  def test_statistics_report
    report = StatisticsReportVisitor.new
    @business_units.each do |business_unit|
      business_unit.accept(report)
    end
    assert_equal 6000, report.total_cost
    assert_equal 235, report.assigned_hours
  end

end