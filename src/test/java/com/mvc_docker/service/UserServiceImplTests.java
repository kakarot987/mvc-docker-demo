package com.mvc_docker.service;
import com.mvc_docker.entity.*;
import com.mvc_docker.repository.UserRepository;
import org.junit.jupiter.api.Test;
import java.util.Optional;
import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;
class UserServiceImplTests {
    private final UserRepository repo = mock(UserRepository.class);
    private final UserServiceImpl service = new UserServiceImpl(repo);
    private UserDto dto(String phone, String address) {
        return UserDto.builder().name("Alice").email("alice@example.com").phone(phone).address(address).build();
    }
    @Test void createPersistsFields() {
        when(repo.save(any(User.class))).thenAnswer(inv -> { User u=inv.getArgument(0);u.setId(1L);return u; });
        UserDto created=service.createUser(dto("555-0100","Test Street"));
        assertEquals("555-0100",created.getPhone()); assertEquals("Test Street",created.getAddress());
        verify(repo).save(argThat(u -> u.getPhone().equals("555-0100") && u.getAddress().equals("Test Street")));
    }
    @Test void updatePersistsFields() {
        User old=User.builder().id(2L).name("Alice").email("alice@example.com").phone("old").address("old").build();
        when(repo.findById(2L)).thenReturn(Optional.of(old));
        when(repo.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));
        UserDto updated=service.updateUser(2L,dto("new","New Street"));
        assertEquals("new",updated.getPhone()); assertEquals("New Street",updated.getAddress());
    }
}
