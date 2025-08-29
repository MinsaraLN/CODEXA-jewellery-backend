package com.Kalyani.jewellers.CODEXA_backend.controller;

import com.Kalyani.jewellers.CODEXA_backend.model.Category;
import com.Kalyani.jewellers.CODEXA_backend.service.CategoryService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.util.List;


import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;



@RestController
@RequestMapping("/api/categories")
public class CategoryController {
    @Autowired
    private final CategoryService service;

    public CategoryController(CategoryService service) {
        this.service = service;
    }

    @GetMapping
    public List<Category> all() {
        return service.findAll();
    }

    @PostMapping
    public ResponseEntity<Category> create(@RequestBody CreateCategoryRequest req) {
        Category saved = service.create(req.name());
        return ResponseEntity.ok(saved);
    }

    public record CreateCategoryRequest(String name) {}
}
