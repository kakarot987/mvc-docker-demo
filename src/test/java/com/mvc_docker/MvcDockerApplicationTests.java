package com.mvc_docker;

import com.mvc_docker.controller.UserController;
import com.mvc_docker.entity.UserDto;
import com.mvc_docker.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
class MvcDockerApplicationTests {
    @Autowired MockMvc mvc;
    @MockitoBean UserService service;

    private UserDto sample() {
        return UserDto.builder().id(1L).name("Alice").email("alice@example.com")
            .phone("555-0100").address("Test Street").build();
    }
    @Test void createAndReadUser() throws Exception {
        when(service.createUser(any(UserDto.class))).thenReturn(sample());
        when(service.getUserById(1L)).thenReturn(sample());
        mvc.perform(post("/users").contentType("application/json")
            .content("{\"name\":\"Alice\",\"email\":\"alice@example.com\",\"phone\":\"555-0100\",\"address\":\"Test Street\"}"))
            .andExpect(status().isCreated()).andExpect(jsonPath("$.phone").value("555-0100"))
            .andExpect(jsonPath("$.address").value("Test Street"));
        mvc.perform(get("/users/1")).andExpect(status().isOk())
            .andExpect(jsonPath("$.email").value("alice@example.com"));
    }
    @Test void updateAndDeleteUser() throws Exception {
        when(service.updateUser(eq(1L), any(UserDto.class))).thenReturn(sample());
        mvc.perform(put("/users/1").contentType("application/json")
            .content("{\"name\":\"Alice\",\"email\":\"alice@example.com\",\"phone\":\"555-0100\",\"address\":\"Test Street\"}"))
            .andExpect(status().isOk()).andExpect(jsonPath("$.address").value("Test Street"));
        mvc.perform(delete("/users/1")).andExpect(status().isNoContent());
        verify(service).deleteUser(1L);
    }
    @Test void invalidUserReturns400() throws Exception {
        mvc.perform(post("/users").contentType("application/json")
            .content("{\"name\":\"\",\"email\":\"bad\",\"phone\":\"\",\"address\":\"\"}"))
            .andExpect(status().isBadRequest());
        verifyNoInteractions(service);
    }
}
