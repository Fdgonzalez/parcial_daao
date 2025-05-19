class BusinessUnit
  def accept(_visitor)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

class Employee < BusinessUnit
  attr_reader :name, :salary, :worked_hours

  def initialize(name, salary, worked_hours)
    @name = name
    @salary = salary
    @worked_hours = worked_hours
  end

  def accept(visitor)
    visitor.visit_employee(self)
  end
end

class Department < BusinessUnit
  attr_reader :name, :employees, :budget

  def initialize(name, budget)
    @name = name
    @employees = []
    @budget = budget
  end

  def assign_employee(employee)
    @employees.push(employee)
  end

  def accept(visitor)
    visitor.visit_department(self)
  end
end

class Project < BusinessUnit
  attr_reader :name, :assigned_employees, :timespan, :status

  def initialize(name, timespan, status)
    @assigned_employees = []
    @name = name
    @timespan = timespan
    @status = status
  end

  def assign_employee(employee)
    @assigned_employees.push(employee)
  end

  def accept(visitor)
    visitor.visit_project(self)
  end
end

class BusinessUnitVisitor
  def visit_department(_department)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
  
  def visit_employee(_employee)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def visit_project(_project)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end

class PlainTextReportVisitor < BusinessUnitVisitor
  def initialize()
    @report = ""
  end

  def visit_department(department)
    @report += "Department #{department.name}\n"
    @report += "Budget: $#{department.budget}\n"
    assigned_hours = 0
    total_cost = 0
    department.employees.each do |employee|
      assigned_hours += employee.worked_hours
      total_cost += employee.salary
    end
    @report += "Assigned hours: #{assigned_hours}\n"
    @report += "Total cost: $#{total_cost}\n"
  end
  
  def visit_employee(employee)
    @report += "Employee #{employee.name}\n"
    @report += "Worked hours: #{employee.worked_hours}\n"
    @report += "Salary: $#{employee.salary}\n"
  end

  def visit_project(project)
    @report += "Project #{project.name}\n"
    @report += "Status: #{project.status}\n"
    assigned_hours = 0
    total_cost = 0
    project.assigned_employees.each do |employee|
      assigned_hours += employee.worked_hours
      total_cost += employee.salary
    end
    @report += "Assigned hours: #{assigned_hours}\n"
    @report += "Total cost: $#{total_cost}\n"
  end

  def get_report()
    return @report
  end
end

class StatisticsReportVisitor < BusinessUnitVisitor
  attr_reader :total_cost, :assigned_hours

  def initialize()
    @total_cost = 0
    @assigned_hours = 0
  end

  def visit_department(department)
    department.employees.each do |employee|
      @assigned_hours += employee.worked_hours
      @total_cost += employee.salary
    end
  end
  
  def visit_employee(employee)
    @assigned_hours += employee.worked_hours
    @total_cost += employee.salary
  end

  def visit_project(project)
    project.assigned_employees.each do |employee|
      @assigned_hours += employee.worked_hours
      @total_cost += employee.salary
    end
  end
end

