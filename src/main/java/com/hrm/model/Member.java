package com.hrm.model;

public class Member {
    private int id;
    private int committeeId;
    private String name;
    private String roleTitle;
    private String staffNo;
    private String designation;
    private String department;
    private String officeNo;
    private String phone;
    private String photoPath;

    public int getId() {
        return id;
    }
    public void setId(int id) {
        this.id = id;
    }

    public int getCommitteeId() {
        return committeeId;
    }
    public void setCommitteeId(int committeeId) {
        this.committeeId = committeeId;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public String getRoleTitle() {
        return roleTitle;
    }
    public void setRoleTitle(String roleTitle) {
        this.roleTitle = roleTitle;
    }

    public String getStaffNo() {
        return staffNo;
    }
    public void setStaffNo(String staffNo) {
        this.staffNo = staffNo;
    }

    public String getDesignation() {
        return designation;
    }
    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public String getDepartment() {
        return department;
    }
    public void setDepartment(String department) {
        this.department = department;
    }

    public String getOfficeNo() {
        return officeNo;
    }
    public void setOfficeNo(String officeNo) {
        this.officeNo = officeNo;
    }

    public String getPhone() {
        return phone;
    }
    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getPhotoPath() {
        return photoPath;
    }
    public void setPhotoPath(String photoPath) {
        this.photoPath = photoPath;
    }
}
